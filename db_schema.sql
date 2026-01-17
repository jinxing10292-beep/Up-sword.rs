-- Up-Sword: Battle / Inventory / Missions / Achievements schema
 
-- Enable required extension (usually already enabled on Supabase)
-- create extension if not exists "pgcrypto";
 
-- 0) Profile: store current weapon type (normal/hidden)
alter table public.profiles
add column if not exists current_weapon_type text not null default 'normal'
check (current_weapon_type in ('normal','hidden'));

-- Track which base weapon the user currently holds (for discovery & catalog)
alter table public.profiles
add column if not exists current_weapon_key text not null default 'normal_01';

-- Ensure profiles.username exists for GM/Battle pages
alter table public.profiles
add column if not exists username text;

create index if not exists idx_profiles_username on public.profiles(username);
do $$ begin
  if not exists (
    select 1 from pg_constraint where conname = 'profiles_username_unique'
  ) then
    begin
      alter table public.profiles add constraint profiles_username_unique unique (username);
    exception when others then
      -- if duplicates exist, skip unique until cleaned
      raise notice 'profiles.username uniqueness not enforced due to existing duplicates';
    end;
  end if;
end $$;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'nickname'
  ) then
    if not exists (
      select 1
      from pg_constraint
      where conname = 'profiles_nickname_len_25'
    ) then
      execute 'alter table public.profiles add constraint profiles_nickname_len_25 check (char_length(nickname) <= 25)';
    end if;
  end if;
end$$;

create index if not exists idx_profiles_nickname on public.profiles(nickname);
 
-- 1) User swords: every sword the user owns
create table if not exists public.user_swords (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  sword_level int not null default 1,
  sword_name text not null,
  weapon_type text check (weapon_type in ('normal','hidden')),
  weapon_key text,
  variant_id int,
  attack int not null default 10,
  rarity text not null default 'common' check (rarity in ('common','rare','epic','legendary')),
  created_at timestamptz not null default now()
);
 
create index if not exists idx_user_swords_user_id on public.user_swords(user_id);
 
-- 2) Inventory slots (max 3): what swords are equipped/active
create table if not exists public.user_inventory_slots (
  user_id uuid not null references auth.users(id) on delete cascade,
  slot smallint not null check (slot in (1,2,3)),
  sword_id uuid references public.user_swords(id) on delete set null,
  updated_at timestamptz not null default now(),
  primary key (user_id, slot),
  unique (user_id, sword_id)
);
 
create index if not exists idx_inventory_slots_user on public.user_inventory_slots(user_id);
 
-- 3) Battles: async PvP (online/offline no distinction)
create table if not exists public.battles (
  id uuid primary key default gen_random_uuid(),
  player1_id uuid not null references auth.users(id) on delete cascade,
  player2_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'in_progress' check (status in ('in_progress','completed','cancelled')),
  current_turn uuid not null,
  state jsonb not null default '{}'::jsonb,
  winner_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
 
create index if not exists idx_battles_players on public.battles(player1_id, player2_id);
create index if not exists idx_battles_status on public.battles(status);
 
-- 4) Mission definitions + user progress
create table if not exists public.missions (
  id text primary key,
  title text not null,
  description text not null,
  target int not null default 1,
  reward_gold int not null default 0,
  active boolean not null default true
);
 
create table if not exists public.user_missions (
  user_id uuid not null references auth.users(id) on delete cascade,
  mission_id text not null references public.missions(id) on delete cascade,
  progress int not null default 0,
  completed boolean not null default false,
  claimed boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, mission_id)
);
 
-- 5) Achievement definitions + user achievements
create table if not exists public.achievements (
  id text primary key,
  title text not null,
  description text not null,
  target int not null default 1,
  badge text,
  active boolean not null default true
);
 
create table if not exists public.user_achievements (
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_id text not null references public.achievements(id) on delete cascade,
  progress int not null default 0,
  unlocked boolean not null default false,
  unlocked_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, achievement_id)
);

-- Track user discovery progress per weapon type for the collection UI
create table if not exists public.user_weapon_discoveries (
  user_id uuid not null references auth.users(id) on delete cascade,
  weapon_type text not null check (weapon_type in ('normal','hidden')),
  weapon_key text not null,
  max_discovered_level int not null default 0 check (max_discovered_level between 0 and 20),
  updated_at timestamptz not null default now(),
  primary key (user_id, weapon_type, weapon_key)
);

-- Sword catalog (33 kinds: 30 normal + 3 hidden). image_pattern may contain '{lvl}' placeholder
create table if not exists public.sword_catalog (
  weapon_key text primary key,
  weapon_type text not null check (weapon_type in ('normal','hidden')),
  name_ko text not null,
  image_pattern text
);

create index if not exists idx_sword_catalog_type on public.sword_catalog(weapon_type);
 
-- updated_at trigger helper
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;
 
drop trigger if exists trg_battles_updated_at on public.battles;
create trigger trg_battles_updated_at
before update on public.battles
for each row execute function public.set_updated_at();
 
drop trigger if exists trg_user_missions_updated_at on public.user_missions;
create trigger trg_user_missions_updated_at
before update on public.user_missions
for each row execute function public.set_updated_at();
 
drop trigger if exists trg_user_achievements_updated_at on public.user_achievements;
create trigger trg_user_achievements_updated_at
before update on public.user_achievements
for each row execute function public.set_updated_at();
 
drop trigger if exists trg_inventory_slots_updated_at on public.user_inventory_slots;
create trigger trg_inventory_slots_updated_at
before update on public.user_inventory_slots
for each row execute function public.set_updated_at();
 
-- RLS: enable on all tables (including definition tables)
alter table public.user_swords enable row level security;
alter table public.user_inventory_slots enable row level security;
alter table public.battles enable row level security;
alter table public.missions enable row level security;
alter table public.achievements enable row level security;
alter table public.user_missions enable row level security;
alter table public.user_achievements enable row level security;
alter table public.user_weapon_discoveries enable row level security;
alter table public.sword_catalog enable row level security;
 
-- user_swords policies
drop policy if exists "user_swords_select_own" on public.user_swords;
create policy "user_swords_select_own" on public.user_swords
for select using (auth.uid() = user_id);
 
drop policy if exists "user_swords_insert_own" on public.user_swords;
create policy "user_swords_insert_own" on public.user_swords
for insert with check (auth.uid() = user_id);
 
drop policy if exists "user_swords_update_own" on public.user_swords;
create policy "user_swords_update_own" on public.user_swords
for update using (auth.uid() = user_id);
 
-- inventory slots policies
drop policy if exists "inv_slots_select_own" on public.user_inventory_slots;
create policy "inv_slots_select_own" on public.user_inventory_slots
for select using (auth.uid() = user_id);
 
drop policy if exists "inv_slots_insert_own" on public.user_inventory_slots;
create policy "inv_slots_insert_own" on public.user_inventory_slots
for insert with check (auth.uid() = user_id);
 
drop policy if exists "inv_slots_update_own" on public.user_inventory_slots;
create policy "inv_slots_update_own" on public.user_inventory_slots
for update using (auth.uid() = user_id);
 
-- battles policies (either player can read/update)
drop policy if exists "battles_select_players" on public.battles;
create policy "battles_select_players" on public.battles
for select using (auth.uid() = player1_id or auth.uid() = player2_id);
 
drop policy if exists "battles_insert_players" on public.battles;
create policy "battles_insert_players" on public.battles
for insert with check (auth.uid() = player1_id or auth.uid() = player2_id);
 
drop policy if exists "battles_update_players" on public.battles;
create policy "battles_update_players" on public.battles
for update using (auth.uid() = player1_id or auth.uid() = player2_id);
 
-- missions/achievements definition tables: readable by everyone
drop policy if exists "missions_select_all" on public.missions;
create policy "missions_select_all" on public.missions
for select using (true);
 
drop policy if exists "achievements_select_all" on public.achievements;
create policy "achievements_select_all" on public.achievements
for select using (true);

-- sword_catalog readable by everyone
drop policy if exists "sword_catalog_select_all" on public.sword_catalog;
create policy "sword_catalog_select_all" on public.sword_catalog
for select using (true);

-- discoveries: users can read/write their own
drop policy if exists "discoveries_select_own" on public.user_weapon_discoveries;
create policy "discoveries_select_own" on public.user_weapon_discoveries
for select using (auth.uid() = user_id);

drop policy if exists "discoveries_insert_own" on public.user_weapon_discoveries;
create policy "discoveries_insert_own" on public.user_weapon_discoveries
for insert with check (auth.uid() = user_id);

drop policy if exists "discoveries_update_own" on public.user_weapon_discoveries;
create policy "discoveries_update_own" on public.user_weapon_discoveries
for update using (auth.uid() = user_id);
 
-- missions/achievements user tables policies
drop policy if exists "user_missions_select_own" on public.user_missions;
create policy "user_missions_select_own" on public.user_missions
for select using (auth.uid() = user_id);
 
drop policy if exists "user_missions_insert_own" on public.user_missions;
create policy "user_missions_insert_own" on public.user_missions
for insert with check (auth.uid() = user_id);
 
drop policy if exists "user_missions_update_own" on public.user_missions;
create policy "user_missions_update_own" on public.user_missions
for update using (auth.uid() = user_id);
 
drop policy if exists "user_achievements_select_own" on public.user_achievements;
create policy "user_achievements_select_own" on public.user_achievements
for select using (auth.uid() = user_id);
 
drop policy if exists "user_achievements_insert_own" on public.user_achievements;
create policy "user_achievements_insert_own" on public.user_achievements
for insert with check (auth.uid() = user_id);
 
drop policy if exists "user_achievements_update_own" on public.user_achievements;
create policy "user_achievements_update_own" on public.user_achievements
for update using (auth.uid() = user_id);
 
-- Seed missions/achievements (safe upserts)
insert into public.missions(id, title, description, target, reward_gold, active)
values
  ('battle_play_1', '첫 배틀', '배틀 1회 진행', 1, 1000, true),
  ('battle_win_1', '첫 승리', '배틀 1회 승리', 1, 3000, true),
  ('battle_play_5', '전장의 냄새', '배틀 5회 진행', 5, 5000, true),
  ('battle_win_3', '승리의 감각', '배틀 3회 승리', 3, 7000, true),
  ('collect_sword_3', '3자루의 서약', '검 3개 보유', 3, 4000, true)
on conflict (id) do update set
  title = excluded.title,
  description = excluded.description,
  target = excluded.target,
  reward_gold = excluded.reward_gold,
  active = excluded.active;

-- Seed 30 normal + 3 hidden catalog entries
do $$
declare i int;
begin
  for i in 1..30 loop
    insert into public.sword_catalog(weapon_key, weapon_type, name_ko, image_pattern)
    values (format('normal_%02s', i), 'normal', format('일반검 %s', i), 'images/swords/normal_%02s/level_{lvl}.png')
    on conflict (weapon_key) do nothing;
  end loop;
  for i in 1..3 loop
    insert into public.sword_catalog(weapon_key, weapon_type, name_ko, image_pattern)
    values (format('hidden_%02s', i), 'hidden', format('히든검 %s', i), 'images/swords/hidden_%02s/level_{lvl}.png')
    on conflict (weapon_key) do nothing;
  end loop;
end$$;
 
insert into public.achievements(id, title, description, target, badge, active)
values
  ('wins_10', '승리 10회', '배틀에서 10회 승리', 10, 'wins_10', true),
  ('wins_30', '전장의 상수', '배틀에서 30회 승리', 30, 'wins_30', true),
  ('collect_3', '검 수집가', '검을 3개 보유', 3, 'collect_3', true),
  ('collect_10', '무기고의 주인', '검을 10개 보유', 10, 'collect_10', true)
on conflict (id) do update set
  title = excluded.title,
  description = excluded.description,
  target = excluded.target,
  badge = excluded.badge,
  active = excluded.active;

-- Weapon variants: 33 weapons x 20 levels (0..19) = 660 unique IDs
-- Base index mapping: normal_01..normal_30 => 1..30, hidden_01..hidden_03 => 31..33
-- unique_id formula: level == 0 ? baseIndex : 33*level + baseIndex (so 34..660 for level >=1)
create table if not exists public.weapon_variants (
  unique_id int primary key,
  weapon_key text not null references public.sword_catalog(weapon_key) on delete cascade,
  level int not null check (level between 0 and 19),
  name_ko text not null
);

create index if not exists idx_weapon_variants_key_level on public.weapon_variants(weapon_key, level);

do $$
declare i int; baseIndex int; key text;
begin
  -- normal 30 -> baseIndex 1..30
  for i in 1..30 loop
    key := format('normal_%02s', i);
    for level in 0..19 loop
      insert into public.weapon_variants(unique_id, weapon_key, level, name_ko)
      values (
        case when level = 0 then i else 33*level + i end,
        key,
        level,
        format('일반검 %s +%s', i, level)
      ) on conflict (unique_id) do nothing;
    end loop;
  end loop;
  -- hidden 3 -> baseIndex 31..33
  for i in 1..3 loop
    key := format('hidden_%02s', i);
    for level in 0..19 loop
      insert into public.weapon_variants(unique_id, weapon_key, level, name_ko)
      values (
        case when level = 0 then 30 + i else 33*level + (30 + i) end,
        key,
        level,
        format('히든검 %s +%s', i, level)
      ) on conflict (unique_id) do nothing;
    end loop;
  end loop;
end$$;
