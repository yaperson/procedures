-- Supabase Schema pour l'application Procédures

-- 1. Table des catégories
CREATE TABLE categories (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  name text NOT NULL,
  description text
);

-- 2. Table des procédures
CREATE TABLE procedures (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
  title text NOT NULL,
  content text,
  steps jsonb DEFAULT '[]'::jsonb,
  mermaid_chart text,
  version text DEFAULT '1.0',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- 3. Table des suggestions
CREATE TABLE suggestions (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  procedure_id uuid REFERENCES procedures(id) ON DELETE CASCADE,
  author_name text,
  content text NOT NULL,
  status text DEFAULT 'new', -- 'new', 'read', 'implemented'
  upvotes integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now()
);

-- RLS (Row Level Security) - Politique d'accès simple
-- (Lecture publique pour le frontend, écriture réservée aux utilisateurs authentifiés)

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE procedures ENABLE ROW LEVEL SECURITY;
ALTER TABLE suggestions ENABLE ROW LEVEL SECURITY;

-- Lecture publique
CREATE POLICY "Lecture publique des catégories" ON categories FOR SELECT USING (true);
CREATE POLICY "Lecture publique des procédures" ON procedures FOR SELECT USING (true);

-- Tout le monde peut proposer une suggestion
CREATE POLICY "Tout le monde peut ajouter une suggestion" ON suggestions FOR INSERT WITH CHECK (true);

-- L'administrateur peut tout faire
CREATE POLICY "Admin peut tout modifier dans categories" ON categories USING (auth.role() = 'authenticated');
CREATE POLICY "Admin peut tout modifier dans procedures" ON procedures USING (auth.role() = 'authenticated');
CREATE POLICY "Admin peut lire les suggestions" ON suggestions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin peut modifier les suggestions" ON suggestions FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin peut supprimer les suggestions" ON suggestions FOR DELETE USING (auth.role() = 'authenticated');
