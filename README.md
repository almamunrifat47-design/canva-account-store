# Canva Account Store

Frontend: static HTML/CSS/JS
Backend: Supabase
Hosting: Vercel

## Setup
1. Create a Supabase project.
2. Run `supabase.sql` in Supabase SQL Editor.
3. Open `config.js` and add your Supabase URL and anon key.
4. Create an admin user in Supabase Authentication > Users.
5. Add that user's email to the `admin_users` table.
6. Deploy the folder to Vercel.

Public pages:
- `/index.html`
- `/order.html`
- `/order-status.html`

Admin:
- `/admin.html`
