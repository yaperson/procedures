<template>
  <div class="guide-container">
    <div class="header">
      <a :href="`${baseUrl}admin/dashboard`" class="back-link">← Retour au tableau de bord</a>
      <h1>Guide d'utilisation de l'Éditeur</h1>
      <p class="subtitle">Découvrez comment rédiger, structurer et visualiser vos procédures étape par étape.</p>
    </div>

    <!-- Sommaire Rapide -->
    <nav class="toc-card card">
      <h2>Sommaire</h2>
      <ul>
        <li><a href="#structure">1. Structuration par Étapes (H2)</a></li>
        <li><a href="#condition">2. Blocs de Condition (Si / Sinon)</a></li>
        <li><a href="#tableaux">3. Gestion des Tableaux</a></li>
        <li><a href="#disposition">4. Modes de Disposition et Aperçu</a></li>
        <li><a href="#lisibilite">5. Lisibilité et Vue Épurée</a></li>
        <li><a href="#enregistrement">6. Enregistrement et Versionnage</a></li>
      </ul>
    </nav>

    <div class="guide-sections">
      <!-- Section 1 : Structure & Étapes -->
      <section id="structure" class="card guide-card">
        <h2>1. Structuration par Étapes (H2)</h2>
        <p>Pour qu'une procédure soit claire et génère automatiquement son diagramme de flux ainsi que sa liste de contrôle, il est essentiel d'utiliser les titres <strong>Étape (H2)</strong>.</p>
        
        <div class="info-box">
          <strong>Règle importante :</strong> Chaque titre formaté en <strong>H2 (Étape)</strong> devient une étape officielle de la procédure.
        </div>

        <ul class="guide-list">
          <li><strong>Bouton "Étape (H2)" :</strong> Cliquez sur le bouton <code>Étape (H2)</code> dans la barre d'outils pour transformer n'importe quel titre en étape.</li>
          <li><strong>Génération automatique :</strong> Les étapes H2 sont automatiquement extraites pour construire le schéma fonctionnel (diagramme Mermaid) et la checklist interactive sur le côté de la procédure.</li>
          <li><strong>Titres secondaires :</strong> Utilisez H1 pour le titre principal, et H3 / H4 pour les sous-sections d'une même étape.</li>
        </ul>
      </section>

      <!-- Section 2 : Conditions -->
      <section id="condition" class="card guide-card">
        <h2>2. Blocs de Condition (Si / Sinon)</h2>
        <p>Les blocs de condition permettent de créer des choix décisionnels interactifs dans vos procédures sans écrire de code.</p>
        
        <div class="steps-guide">
          <div class="step-guide-item">
            <span class="step-num">1</span>
            <div>
              <strong>Insérer une condition :</strong> Cliquez sur le bouton <code>Condition (Si/Sinon)</code> dans la barre d'outils. Une carte s'insère dans l'éditeur.
            </div>
          </div>
          <div class="step-guide-item">
            <span class="step-num">2</span>
            <div>
              <strong>Formuler la question :</strong> Remplissez le champ "Question ou Condition" (ex: <em>Le client a-t-il fourni un justificatif ?</em>).
            </div>
          </div>
          <div class="step-guide-item">
            <span class="step-num">3</span>
            <div>
              <strong>Configurer les branchements :</strong>
              <ul>
                <li><strong>Étape suivante :</strong> Poursuit le déroulement normal de la procédure.</li>
                <li><strong>Fin de procédure :</strong> Arrête le flux à cette étape.</li>
                <li><strong>Sauter vers une étape :</strong> Choisissez directement dans la liste déroulante l'étape (H2) vers laquelle rediriger l'utilisateur.</li>
                <li><strong>Autre (texte libre) :</strong> Saisissez une action spécifique si aucune étape n'est ciblée.</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      <!-- Section 3 : Tableaux -->
      <section id="tableaux" class="card guide-card">
        <h2>3. Gestion des Tableaux</h2>
        <p>Les tableaux permettent d'organiser des données complexes (configurations, matrices, listes de matériels).</p>
        
        <ul class="guide-list">
          <li><strong>Insérer un tableau :</strong> Cliquez sur <code>Tableau</code> dans la barre d'outils pour insérer un tableau 3x3 par défaut.</li>
          <li><strong>Barre d'outils contextuelle :</strong> Dès que votre curseur est positionné dans une cellule de tableau, des boutons d'action s'affichent automatiquement :
            <div class="inline-buttons">
              <span class="mini-btn">+ Ligne</span>
              <span class="mini-btn">- Ligne</span>
              <span class="mini-btn">+ Colonne</span>
              <span class="mini-btn">- Colonne</span>
              <span class="mini-btn danger">Supprimer tableau</span>
            </div>
          </li>
          <li><strong>Délimitation claire :</strong> Tous les tableaux sont mis en forme automatiquement avec des bordures nettes séparant chaque colonne et des lignes alternées pour une meilleure lisibilité.</li>
        </ul>
      </section>

      <!-- Section 4 : Disposition et Aperçu -->
      <section id="disposition" class="card guide-card">
        <h2>4. Modes de Disposition et Panneau d'Aperçu</h2>
        <p>Vous pouvez personnaliser votre espace de travail grâce au sélecteur de disposition situé en haut à droite du champ de contenu :</p>
        
        <div class="mode-grid">
          <div class="mode-item">
            <strong>Côte à côte :</strong> Place l'éditeur à gauche et le panneau d'aperçu à droite (idéal sur grand écran).
          </div>
          <div class="mode-item">
            <strong>À la suite :</strong> Place le panneau d'aperçu en dessous du champ de rédaction.
          </div>
          <div class="mode-item">
            <strong>Éditeur seul :</strong> Masque le panneau d'aperçu pour offrir une zone de rédaction maximale.
          </div>
          <div class="mode-item">
            <strong>Aperçu seul :</strong> Masque l'éditeur pour observer le rendu global en grand format.
          </div>
        </div>

        <h3>Bascule d'aperçu en direct</h3>
        <p>Dans le panneau d'aperçu, deux onglets vous permettent d'examiner le travail en temps réel :</p>
        <ul>
          <li><strong>Diagramme :</strong> Affiche le logigramme fonctionnel généré automatiquement.</li>
          <li><strong>Aperçu Résultat :</strong> Affiche le document final exact tel qu'il apparaîtra aux utilisateurs.</li>
        </ul>
      </section>

      <!-- Section 5 : Lisibilité -->
      <section id="lisibilite" class="card guide-card">
        <h2>5. Lisibilité et Vue Épurée</h2>
        <p>L'interface a été conçue pour éviter la fatigue visuelle et convenir aux lecteurs dyslexiques :</p>
        <ul class="guide-list">
          <li><strong>Interface sans emoji :</strong> Élimination des symboles superflus dans l'éditeur et la documentation pour une concentration maximale.</li>
          <li><strong>Bouton "Vue Épurée" :</strong> Présent sur la page de chaque procédure, il permet d'augmenter l'interlignage et d'appliquer un fond crème reposant (`#faf9f5`) d'un seul clic.</li>
        </ul>
      </section>

      <!-- Section 6 : Enregistrement -->
      <section id="enregistrement" class="card guide-card">
        <h2>6. Enregistrement et Versionnage</h2>
        <ul class="guide-list">
          <li>Lors de la création d'une nouvelle procédure, sa version initiale est fixée à <code>1.0</code>.</li>
          <li>À chaque modification enregistrée, la version est automatiquement incrémentée de <code>0.1</code> (ex: 1.0 → 1.1 → 1.2).</li>
          <li>Cliquez sur le bouton <strong>Enregistrer</strong> en bas de page pour valider vos changements.</li>
        </ul>
      </section>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../../lib/supabase';

const baseUrl = import.meta.env.BASE_URL;
const authChecked = ref(false);

onMounted(async () => {
  if (supabase.supabaseUrl !== 'https://placeholder.supabase.co') {
    const { data } = await supabase.auth.getSession();
    if (!data.session) {
      window.location.href = `${baseUrl}admin/login`;
      return;
    }
  }
  authChecked.value = true;
});
</script>

<style scoped>
.guide-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 1.5rem 1rem;
}

.header {
  margin-bottom: 2rem;
}

.back-link {
  color: var(--text-muted);
  text-decoration: none;
  font-weight: 500;
  display: inline-block;
  margin-bottom: 1rem;
}

.back-link:hover {
  color: var(--primary);
}

h1 {
  margin: 0 0 0.5rem 0;
  font-size: 2rem;
  color: var(--text-main);
}

.subtitle {
  color: var(--text-muted);
  font-size: 1.05rem;
  margin: 0;
}

.toc-card {
  background: #f8fafc;
  border: 1px solid var(--border);
  padding: 1.25rem 1.5rem;
  margin-bottom: 2rem;
  border-radius: 8px;
}

.toc-card h2 {
  font-size: 1.1rem;
  margin-top: 0;
  margin-bottom: 0.75rem;
  color: #334155;
}

.toc-card ul {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 0.5rem 1rem;
  margin: 0;
  padding-left: 1.25rem;
}

.toc-card a {
  color: var(--primary);
  text-decoration: none;
  font-weight: 500;
}

.toc-card a:hover {
  text-decoration: underline;
}

.guide-sections {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.guide-card {
  padding: 1.75rem;
  background: white;
  border: 1px solid var(--border);
  border-radius: 10px;
}

.guide-card h2 {
  margin-top: 0;
  margin-bottom: 1rem;
  font-size: 1.35rem;
  color: var(--text-main);
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #f1f5f9;
}

.guide-card h3 {
  font-size: 1.1rem;
  margin-top: 1.5rem;
  margin-bottom: 0.75rem;
  color: #334155;
}

.info-box {
  background-color: #eff6ff;
  border-left: 4px solid #3b82f6;
  padding: 0.85rem 1rem;
  border-radius: 0 6px 6px 0;
  margin: 1rem 0;
  color: #1e3a8a;
  font-size: 0.95rem;
}

.guide-list {
  line-height: 1.7;
  color: #334155;
  padding-left: 1.25rem;
  margin-bottom: 0;
}

.guide-list li {
  margin-bottom: 0.65rem;
}

.steps-guide {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-top: 1rem;
}

.step-guide-item {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  background: #f8fafc;
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.step-num {
  width: 28px;
  height: 28px;
  background: var(--primary);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.9rem;
  flex-shrink: 0;
}

.mode-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin: 1rem 0;
}

.mode-item {
  background: #f8fafc;
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  font-size: 0.95rem;
  color: #334155;
}

.mode-item strong {
  display: block;
  color: #0f172a;
  margin-bottom: 0.25rem;
}

.inline-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
  margin-top: 0.5rem;
}

.mini-btn {
  background: #f1f5f9;
  border: 1px solid #cbd5e1;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
  color: #334155;
}

.mini-btn.danger {
  background: #fef2f2;
  color: #ef4444;
  border-color: #fca5a5;
}

code {
  background: #f1f5f9;
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  font-family: monospace;
  font-size: 0.9em;
  color: #0f172a;
}
</style>
