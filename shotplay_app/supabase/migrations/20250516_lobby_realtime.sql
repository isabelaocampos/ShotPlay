-- Run this in the Supabase SQL editor to enable reactive waiting-room sync.
--
-- 1) Postgres Changes: emit participation INSERT/UPDATE/DELETE to connected clients.
-- 2) Profiles RLS: allow users to read usernames of other players in the same room.

-- ── Realtime publication for participation ───────────────────────────────────
alter publication supabase_realtime add table public.participation;

-- ── Profiles visible to co-participants in the same room ─────────────────────
-- Skip if a similar policy already exists.
create policy "profiles_select_room_participants"
on public.profiles
for select
to authenticated
using (
  exists (
    select 1
    from public.participation mine
    join public.participation theirs
      on mine.room_id = theirs.room_id
    where mine.user_id = auth.uid()
      and theirs.user_id = profiles.id
  )
);
