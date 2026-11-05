-- M7 GOAT : catalogue Camille aligné sur le site (16 offres des affiches, novembre 2026).
-- Idempotent : relancer ne crée pas de doublon. Les 5 anciens produits sont désactivés, pas supprimés
-- (les anciennes commandes peuvent y faire référence).
\set ON_ERROR_STOP on
BEGIN;
CREATE TEMP TABLE m7_agent ON COMMIT DROP AS SELECT id FROM camille.agents WHERE site_slug = 'm7goat';
DO $$ BEGIN IF (SELECT count(*) FROM m7_agent) <> 1 THEN RAISE EXCEPTION 'boutique m7goat introuvable ou en double'; END IF; END $$;
UPDATE camille.products SET active = false, updated_at = NOW()
  WHERE agent_id = (SELECT id FROM m7_agent) AND product_url IN ('elixir','shampooing','spray','soin','coffret');
CREATE TEMP TABLE m7_nouveaux (lien text, nom text, description text, prix numeric, categorie text, image text, ordre int) ON COMMIT DROP;
INSERT INTO m7_nouveaux VALUES
  ('elixir-shampooing', 'Duo Élixir & Shampooing', 'Le duo de base : laver la racine, puis la nourrir chaque jour. Contenu : Élixir capillaire · Shampooing nourrissant.', 12000, 'Duo', 'https://m7goat.vps.buyticle.com/img/c-elixir-shampooing.webp', 1),
  ('elixir-spray-shampooing', 'Trio Élixir, Spray & Shampooing', 'Laver, nourrir, tonifier : trois gestes, un seul combo. Contenu : Élixir capillaire · Spray tonifiant · Shampooing nourrissant.', 17000, 'Trio', 'https://m7goat.vps.buyticle.com/img/c-elixir-spray-shampooing.webp', 2),
  ('routine-33', 'Routine complète avec dermaroller', 'Cinq pièces pour traiter le cheveu de la racine à la pointe. Contenu : Élixir capillaire · Shampooing nourrissant · Spray tonifiant · Crème hydratante · Dermaroller.', 33000, 'Routine', 'https://m7goat.vps.buyticle.com/img/c-routine-33.webp', 3),
  ('gamme-complete-dermaroller', 'Gamme complète + dermaroller', 'Tous les soins M7 GOAT et le dermaroller : le protocole absolu. Contenu : Shampooing nourrissant · Spray tonifiant · 2 × Élixir capillaire · Crème hydratante · Épices capillaires · Dermaroller.', 45000, 'Gamme complète', 'https://m7goat.vps.buyticle.com/img/c-gamme-45.webp', 4),
  ('elixir-epices', 'Duo Élixir & Épices capillaires', 'Le plus petit prix pour commencer le rituel M7 GOAT. Contenu : Élixir capillaire · Épices capillaires.', 8500, 'Duo', 'https://m7goat.vps.buyticle.com/img/c-elixir-epices.webp', 5),
  ('elixir-spray', 'Duo Élixir & Spray', 'L''élixir à la racine, le spray sur les longueurs. Contenu : Élixir capillaire · Spray tonifiant.', 10000, 'Duo', 'https://m7goat.vps.buyticle.com/img/c-elixir-spray.webp', 6),
  ('elixir-creme', 'Duo Élixir & Crème hydratante', 'Nourrir la racine et hydrater le cheveu. Contenu : Élixir capillaire · Crème hydratante.', 11000, 'Duo', 'https://m7goat.vps.buyticle.com/img/c-elixir-creme.webp', 7),
  ('elixir-dermaroller', 'Duo Dermaroller & Élixir', 'Le dermaroller ouvre les pores, l''élixir pénètre en profondeur. Contenu : Dermaroller · Élixir capillaire.', 15000, 'Duo', 'https://m7goat.vps.buyticle.com/img/c-dermaroller-elixir.webp', 8),
  ('elixir-shampooing-creme', 'Trio Élixir, Shampooing & Crème', 'Laver, nourrir et hydrater, de la racine à la pointe. Contenu : Élixir capillaire · Shampooing nourrissant · Crème hydratante.', 18000, 'Trio', 'https://m7goat.vps.buyticle.com/img/c-elixir-shampooing-creme.webp', 9),
  ('double-elixir-shampooing', 'Double Élixir & Shampooing', 'Deux élixirs pour tenir la routine plus longtemps. Contenu : 2 × Élixir capillaire · Shampooing nourrissant.', 20000, 'Trio', 'https://m7goat.vps.buyticle.com/img/c-double-elixir.webp', 10),
  ('elixir-creme-dermaroller', 'Trio Élixir, Crème & Dermaroller', 'Le dermaroller prépare, l''élixir et la crème nourrissent. Contenu : Élixir capillaire · Crème hydratante · Dermaroller.', 21000, 'Trio', 'https://m7goat.vps.buyticle.com/img/c-routine-21.webp', 11),
  ('routine-23', 'Routine Élixir, Spray, Shampooing & Crème', 'Quatre soins pour une routine quotidienne complète. Contenu : Élixir capillaire · Spray tonifiant · Shampooing nourrissant · Crème hydratante.', 23000, 'Routine', 'https://m7goat.vps.buyticle.com/img/c-elixir-spray-shampooing-creme.webp', 12),
  ('routine-25', 'Routine Élixir, Crème, Épices & Dermaroller', 'La routine intensive, avec les épices capillaires et le dermaroller. Contenu : Élixir capillaire · Crème hydratante · Épices capillaires · Dermaroller.', 25000, 'Routine', 'https://m7goat.vps.buyticle.com/img/c-routine-25.webp', 13),
  ('routine-28', 'Routine Élixir, Shampooing, Crème & Dermaroller', 'Laver, préparer, nourrir : la routine qui va jusqu''au bout. Contenu : Élixir capillaire · Shampooing nourrissant · Crème hydratante · Dermaroller.', 28000, 'Routine', 'https://m7goat.vps.buyticle.com/img/c-routine-28.webp', 14),
  ('gamme-complete', 'La gamme complète', 'Tous les soins M7 GOAT, livrés dans le sac cadeau. Contenu : Shampooing nourrissant · Spray tonifiant · 2 × Élixir capillaire · Crème hydratante · Épices capillaires.', 35000, 'Gamme complète', 'https://m7goat.vps.buyticle.com/img/c-gamme-35.webp', 15),
  ('dermaroller', 'Dermaroller', 'Le seul soin vendu à l''unité : il prépare le cuir chevelu à absorber les soins. Contenu : Dermaroller.', 10000, 'Dermaroller seul', 'https://m7goat.vps.buyticle.com/img/c-dermaroller.webp', 16);
UPDATE camille.products p SET name = n.nom, description = n.description, price = n.prix, price_max = NULL, currency = 'XAF',
       category = n.categorie, image_url = n.image, sort_order = n.ordre, active = true, updated_at = NOW()
  FROM m7_nouveaux n WHERE p.agent_id = (SELECT id FROM m7_agent) AND p.product_url = n.lien;
INSERT INTO camille.products (agent_id, name, description, price, currency, category, image_url, product_url, sort_order, active)
SELECT (SELECT id FROM m7_agent), n.nom, n.description, n.prix, 'XAF', n.categorie, n.image, n.lien, n.ordre, true
  FROM m7_nouveaux n
 WHERE NOT EXISTS (SELECT 1 FROM camille.products p WHERE p.agent_id = (SELECT id FROM m7_agent) AND p.product_url = n.lien);
-- contrôle : 16 actifs attendus
SELECT count(*) FILTER (WHERE active) AS actifs, count(*) FILTER (WHERE NOT active) AS inactifs FROM camille.products WHERE agent_id = (SELECT id FROM m7_agent);
SELECT product_url, name, price, category, active FROM camille.products WHERE agent_id = (SELECT id FROM m7_agent) ORDER BY active DESC, sort_order;
COMMIT;
