-- Realtime lobby configuration for ShotPlay multiplayer rooms.
-- Run once in the Supabase SQL editor.

alter table public.room
  add column if not exists lobby_settings jsonb not null default '{}';

-- Participants can read lobby settings for rooms they belong to.
create policy if not exists "room_lobby_settings_select_participants"
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

-- Admin can update lobby settings while the room is still in the lobby.
create policy if not exists "room_lobby_settings_update_admin_waiting"
on public.room
for update
to authenticated
using (
  room.admin_id = auth.uid()
  and room.status = 'waiting'
)
with check (
  room.admin_id = auth.uid()
  and room.status = 'waiting'
);
