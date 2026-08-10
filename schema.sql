-- ===================================================
-- Omara Manager v4.0 — Supabase Database Schema
-- IDEA-EG | www.ideaeg.online
-- ===================================================

-- 1. جدول المباني (buildings)
-- كل مستخدم (صاحب حساب) يمتلك سجل مبنى واحد
CREATE TABLE IF NOT EXISTS buildings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  building_no TEXT DEFAULT '',
  union_head TEXT DEFAULT '',
  building_address TEXT DEFAULT '',
  gsheet_url TEXT DEFAULT NULL,
  sandouq NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(owner_user_id)
);

-- 2. جدول حالة التطبيق (app_state)
-- يخزن كل بيانات التطبيق ككائن JSON واحد لكل مبنى
CREATE TABLE IF NOT EXISTS app_state (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  building_id UUID NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
  data JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(building_id)
);

-- 3. تفعيل Row Level Security (RLS)
ALTER TABLE buildings ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_state ENABLE ROW LEVEL SECURITY;

-- 4. سياسات الأمان — كل مستخدم يشوف بياناته بس
CREATE POLICY "Users can view own buildings"
  ON buildings FOR SELECT
  USING (auth.uid() = owner_user_id);

CREATE POLICY "Users can insert own buildings"
  ON buildings FOR INSERT
  WITH CHECK (auth.uid() = owner_user_id);

CREATE POLICY "Users can update own buildings"
  ON buildings FOR UPDATE
  USING (auth.uid() = owner_user_id);

CREATE POLICY "Users can view own app_state"
  ON app_state FOR SELECT
  USING (building_id IN (SELECT id FROM buildings WHERE owner_user_id = auth.uid()));

CREATE POLICY "Users can insert own app_state"
  ON app_state FOR INSERT
  WITH CHECK (building_id IN (SELECT id FROM buildings WHERE owner_user_id = auth.uid()));

CREATE POLICY "Users can update own app_state"
  ON app_state FOR UPDATE
  USING (building_id IN (SELECT id FROM buildings WHERE owner_user_id = auth.uid()));

-- 5. Supabase Storage — باكيت لصور الفواتير
-- (يتم إنشاؤه من لوحة تحكم Supabase أو عبر API)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('invoices', 'invoices', true);
