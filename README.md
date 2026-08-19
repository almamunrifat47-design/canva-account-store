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


## Visual Editor
Open `/editor.html` after signing in as an admin. The editor lets you click, edit, drag, add text/buttons/sections/images, upload images, preview, and save the homepage design to Supabase.
Run the Visual Editor SQL section in `supabase.sql` once to create `site_pages` and the `site-images` storage bucket/policies.
