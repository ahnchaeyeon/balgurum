-- 발구름 응원 보드: 보드 관리 비밀번호로 수정·삭제 (이미 적용됨, 2026-11-17)
-- 기존 cheers 행은 건드리지 않습니다. 공개 API(anon/authenticated)로 직접 UPDATE/DELETE 는 계속 불가능합니다.

create schema if not exists board_private;                       -- Data API 에 노출되지 않는 스키마
revoke all on schema board_private from public, anon, authenticated;

create table if not exists board_private.settings(
  id int primary key default 1 check (id = 1),
  pass_hash text not null,                                        -- bcrypt 해시만 저장
  updated_at timestamptz not null default now()
);
create table if not exists board_private.failed_attempts(at timestamptz not null default now());
revoke all on all tables in schema board_private from public, anon, authenticated;

revoke update, delete on public.cheers from anon, authenticated;
grant select (id) on public.cheers to anon, authenticated;        -- 카드가 수정/삭제 대상 id 를 알 수 있게 (RLS: 공개 글만)

create or replace function board_private.check_pass(p_pass text)
returns text language plpgsql security definer set search_path = '' as $$
declare h text; fails int;
begin
  delete from board_private.failed_attempts where at < now() - interval '1 day';
  select count(*) into fails from board_private.failed_attempts where at > now() - interval '10 minutes';
  if fails >= 10 then return 'locked'; end if;
  select pass_hash into h from board_private.settings where id = 1;
  if h is null then return 'not_set'; end if;
  if p_pass is null or extensions.crypt(p_pass, h) <> h then
    insert into board_private.failed_attempts default values;
    return 'bad_password';
  end if;
  return 'ok';
end $$;
revoke all on function board_private.check_pass(text) from public, anon, authenticated;

create or replace function public.cheer_update(p_id bigint, p_pass text, p_kind text, p_name text, p_msg text, p_public boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare r public.cheers; v text;
begin
  v := board_private.check_pass(p_pass);
  if v <> 'ok' then return jsonb_build_object('ok', false, 'error', v); end if;
  update public.cheers
     set kind = p_kind, name = nullif(btrim(coalesce(p_name, '')), ''), msg = btrim(p_msg), is_public = coalesce(p_public, false)
   where id = p_id
  returning * into r;                                             -- created_at 은 그대로 유지
  if r.id is null then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  return jsonb_build_object('ok', true, 'row', jsonb_build_object('id', r.id, 'created_at', r.created_at, 'kind', r.kind, 'name', r.name, 'msg', r.msg, 'is_public', r.is_public));
exception when check_violation then
  return jsonb_build_object('ok', false, 'error', 'invalid');
end $$;

create or replace function public.cheer_delete(p_id bigint, p_pass text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v text; n int;
begin
  v := board_private.check_pass(p_pass);
  if v <> 'ok' then return jsonb_build_object('ok', false, 'error', v); end if;
  delete from public.cheers where id = p_id;
  get diagnostics n = row_count;
  if n = 0 then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  return jsonb_build_object('ok', true);
end $$;

revoke all on function public.cheer_update(bigint, text, text, text, text, boolean) from public;
revoke all on function public.cheer_delete(bigint, text) from public;
grant execute on function public.cheer_update(bigint, text, text, text, text, boolean) to anon, authenticated;
grant execute on function public.cheer_delete(bigint, text) to anon, authenticated;

-- 비밀번호 설정/변경: Supabase 대시보드 > SQL Editor 에서 '새 비밀번호' 부분만 바꿔 실행하세요. (이 파일에 실제 비밀번호를 적지 마세요)
-- insert into board_private.settings(id, pass_hash) values (1, extensions.crypt('새 비밀번호', extensions.gen_salt('bf')))
--   on conflict (id) do update set pass_hash = excluded.pass_hash, updated_at = now();
