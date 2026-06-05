-- Reconnection & session recovery schema for ShotPlay multiplayer rooms.
-- Run once in the Supabase SQL editor.

-- Room lifecycle + persisted game snapshot (generic JSON).
alter table public.room
  add column if not exists status text not null default 'waiting',
  add column if not exists game_state jsonb,
  add column if not exists updated_at timestamptz default now();

-- Optional: constrain known room statuses.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'room_status_check'
  ) then
    alter table public.room
      add constraint room_status_check
      check (status in ('waiting', 'in_progress', 'finished'));
  end if;
end $$;

-- Participation status values used by the app:
--   active, disconnected, left
-- (column already exists; no rename needed)

-- Allow participants to read persisted game_state for rooms they belong to.
create policy if not exists "room_game_state_select_participants"
on public.room
for select
to authenticated
using (
  exists (
    select 1
    from public.participation p
    where p.room_id = room.id_room
      and p.user_id = auth.uid()
  )
);

-- Allow admin / participants to update game_state while match is active.
create policy if not exists "room_game_state_update_participants"
on public.room
for update
to authenticated
using (
  exists (
    select 1
    from public.participation p
    where p.room_id = room.id_room
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.participation p
    where p.room_id = room.id_room
      and p.user_id = auth.uid()
  )
);
