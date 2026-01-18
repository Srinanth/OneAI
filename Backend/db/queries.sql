-- chats table:
create table chats (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text,
  model_id text not null,
  -- This column stores the latest JSON Artifact. 
  -- We use JSONB so we can query inside it if needed later.
  current_artifact jsonb 
);

-- message table:
create table messages (
  id uuid default gen_random_uuid() primary key,
  chat_id uuid references chats(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  role text not null check (role in ('user', 'assistant', 'system')),
  content text not null
);

-- For development, we will allow public access to row level sec, so i have to lock this down later.
alter table chats enable row level security;
alter table messages enable row level security;

create policy "Public chats access" on chats for all using (true);
create policy "Public messages access" on messages for all using (true);