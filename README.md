# IPHW Rate Calculator

Online IPHW Rate Calculator — **Designed & Developed by Amir Hamza**.

## What was updated

- Existing Main UI/layout is preserved.
- Rate A and Rate B rate matrices are refreshed from `IPHW_RATE_SOURCE.xlsx`.
- Normal Rate display follows the supplied **Ui requirement.xlsx** structure:
  Base Rate, Demand Charge, Customs Fee, ODA, ODA Fuel, Base + Demand, Fuel, Customs Fee and Govt. Fee.
- Login is required before the calculator can be used.
- Per-user access control is supported through Supabase:
  - Normal Rate
  - Rate A
  - Rate B
  - Rate Chart
  - Zone
  - ODA
  - Calculation Logs
- Admin can maintain each user's permissions from **Sidebar → Users**.
- Admin always has full access.

## Required Supabase setup

Run **`supabase_access_control.sql`** once in:

**Supabase Dashboard → SQL Editor → New query → paste SQL → Run**

Then make your admin account an Admin, for example:

```sql
update public.profiles
set is_admin = true
where email = 'YOUR-ADMIN-EMAIL';
```

After that:

1. Login with the admin account.
2. Open **Users** from the left sidebar.
3. Assign permissions user-by-user.
4. Save each user.
5. The user should refresh/re-login to receive the updated access.

### Example permissions

- User XXX → Normal Rate + Rate A
- User YYY → Normal Rate + Rate B + Rate Chart + Zone + ODA

A newly registered user starts with no calculator permissions until an Admin assigns them.

## Deploy on GitHub Pages

1. Push the project files to GitHub.
2. Go to **Settings → Pages**.
3. Select **Deploy from a branch**, choose `main` and `/root`.
4. Save.

## Deploy on Render

1. Push this folder to GitHub.
2. In Render choose **New → Static Site**.
3. Connect the repository.
4. Build Command: leave empty.
5. Publish Directory: `.`
6. Deploy.

The calculator remains browser-based and uses Supabase only for authentication, shared rate updates, calculation logs and user access control.
