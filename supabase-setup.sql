-- 발구름 응원 저장용 테이블 (이미 적용 완료된 설정의 기록용 사본)
create table if not exists public.cheers (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  kind       text not null check (kind in ('cool', 'play', 'next')),
  name       text check (name is null or char_length(name) <= 20),
  msg        text not null check (char_length(btrim(msg)) between 1 and 300),
  is_public  boolean not null default false
);
alter table public.cheers enable row level security;
revoke all on public.cheers from anon, authenticated;
grant insert (kind, name, msg, is_public) on public.cheers to anon, authenticated;
grant select (kind, name, msg, created_at, is_public) on public.cheers to anon, authenticated;
create policy "anyone can send a cheer" on public.cheers for insert to anon, authenticated with check (true);
create policy "anyone can read public cheers" on public.cheers for select to anon, authenticated using (is_public);
create index if not exists cheers_public_created_idx on public.cheers (created_at desc) where is_public;
