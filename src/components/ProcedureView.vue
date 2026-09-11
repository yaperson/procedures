<template>
  <div>
    <div class="breadcrumb" v-if="procedure">
      <a :href="`${baseUrl}category/?id=${procedure.category_id}`">← Retour à la liste</a>
    </div>
    
    <div v-if="loading" class="loading">Chargement de la procédure...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else-if="procedure">
      <header class="proc-header">
        <div class="header-top">
          <h1>{{ procedure.title }}</h1>
          <div class="view-controls">
            <div class="view-mode-tabs" v-if="procedure.mermaid_chart">
              <button 
                type="button"
                class="tab-btn" 
                :class="{ active: viewMode === 'all' }" 
                @click="viewMode = 'all'"
                title="Afficher la procédure et le diagramme"
              >
                Tout afficher
              </button>
              <button 
                type="button"
                class="tab-btn" 
                :class="{ active: viewMode === 'text' }" 
                @click="viewMode = 'text'"
                title="Afficher uniquement le texte de la procédure"
              >
                Procédure
              </button>
              <button 
                type="button"
                class="tab-btn" 
                :class="{ active: viewMode === 'diagram' }" 
                @click="viewMode = 'diagram'"
                title="Afficher uniquement le diagramme de flux"
              >
                Diagramme seul
              </button>
            </div>

            <button 
              type="button" 
              class="simplified-btn"
              :class="{ active: isSimplified }"
              @click="isSimplified = !isSimplified"
              title="Activer la lecture simplifiée et aérée pour réduire la fatigue visuelle"
            >
              Vue Épurée
            </button>

            <button 
              type="button" 
              class="pdf-btn"
              @click="exportPDF"
              title="Télécharger la procédure au format PDF"
            >
              Télécharger en PDF
            </button>
          </div>
        </div>
        <div class="meta">
          <span class="version">Version {{ procedure.version || '1.0' }}</span>
          <span class="date">Mise à jour: {{ new Date(procedure.updated_at).toLocaleDateString() }}</span>
        </div>
      </header>

      <div class="layout-grid" :class="[`mode-${viewMode}`]">
        <div :class="['main-column', { 'simplified-reading': isSimplified }]" v-if="viewMode === 'all' || viewMode === 'text'">
          <div class="content" v-html="procedure.content"></div>
          
          <Mermaid v-if="viewMode === 'all' && procedure.mermaid_chart" :chartText="procedure.mermaid_chart" />
        </div>

        <div class="diagram-column-full" v-if="viewMode === 'diagram' && procedure.mermaid_chart">
          <div class="diagram-full-card">
            <h2 class="diagram-full-title">Diagramme de flux interactif</h2>
            <Mermaid :chartText="procedure.mermaid_chart" />
          </div>
        </div>
        
        <div class="sidebar-column" v-if="viewMode !== 'diagram'">
          <div class="sticky-sidebar">
            <StepList v-if="procedure.steps && procedure.steps.length > 0" :steps="procedure.steps" :procedureId="procedure.id" />
          </div>
        </div>
      </div>

      <hr class="divider" />
      
      <SuggestionForm :procedureId="procedure.id" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../lib/supabase';
import StepList from './StepList.vue';
import Mermaid from './Mermaid.vue';
import SuggestionForm from './SuggestionForm.vue';

const baseUrl = import.meta.env.BASE_URL;
const procedure = ref(null);
const loading = ref(true);
const error = ref('');
const viewMode = ref('all');
const isSimplified = ref(false);

const exportPDF = () => {
  if (typeof window !== 'undefined') {
    window.print();
  }
};

onMounted(async () => {
  const urlParams = new URLSearchParams(window.location.search);
  const id = urlParams.get('id');
  
  if (!id) {
    error.value = "Identifiant de procédure manquant.";
    loading.value = false;
    return;
  }

  try {
    if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
      setTimeout(() => {
        procedure.value = {
          id: id,
          category_id: '1',
          title: 'Onboarding nouveau collaborateur',
          version: '1.2',
          updated_at: '2026-09-01T10:00:00Z',
          content: '<p>Bienvenue dans la procédure d\'intégration. Veuillez suivre scrupuleusement les étapes ci-dessous pour garantir un accueil optimal.</p>',
          steps: [
            'Préparer le poste de travail',
            'Créer les accès informatiques (Email, VPN, Logiciels)',
            'Remettre le livret d\'accueil',
            'Planifier le déjeuner d\'équipe'
          ],
          mermaid_chart: 'graph TD\nA[RH prépare le contrat] --> B[IT crée les accès]\nB --> C[Manager accueille]'
        };
        loading.value = false;
      }, 500);
      return;
    }

    const { data, error: dbError } = await supabase
      .from('procedures')
      .select('*')
      .eq('id', id)
      .single();
      
    if (dbError) throw dbError;
    procedure.value = data;
  } catch (e) {
    console.error(e);
    error.value = "Impossible de charger la procédure.";
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>
.breadcrumb {
  margin-bottom: 2rem;
}

.breadcrumb a {
  color: var(--text-muted);
  text-decoration: none;
  font-weight: 500;
}

.breadcrumb a:hover {
  color: var(--primary);
}

.proc-header {
  margin-bottom: 2.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--border);
}

.proc-header h1 {
  font-size: 2.25rem;
  color: var(--text-main);
  margin-bottom: 0.5rem;
}

.meta {
  display: flex;
  gap: 1rem;
  align-items: center;
  color: var(--text-muted);
  font-size: 0.9rem;
}

.version {
  background-color: #e0f2fe;
  color: #0369a1;
  padding: 0.25rem 0.5rem;
  border-radius: 9999px;
  font-weight: 600;
}

/* Layout Grid for Main Content and Sidebar */
.layout-grid {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

@media (min-width: 992px) {
  .layout-grid {
    flex-direction: row;
    align-items: flex-start;
  }
  
  .main-column {
    flex: 1;
    min-width: 0; /* Prevents overflow in flexbox */
  }
  
  .sidebar-column {
    display: contents;
    position: fixed;
    top: 5em;
    right: 0;
    padding: 1em;
    width: 320px;
    flex-shrink: 0;
  }
  
  .sticky-sidebar {
    position: sticky;
    top: 2rem;
  }
}

.content {
  font-size: 1.1rem;
  line-height: 1.75;
  color: #334155;
  margin-bottom: 2rem;
}

.content :deep(h2) {
  margin-top: 2.5rem;
  margin-bottom: 1.25rem;
  padding: 0.6rem 0.85rem;
  background-color: #f8fafc;
  border-left: 4px solid var(--primary);
  border-radius: 0 6px 6px 0;
  color: var(--text-main);
}

.content :deep(.condition-block) {
  background-color: #f8fafc;
  border: 1px solid #cbd5e1;
  border-left: 4px solid #475569;
  padding: 1.25rem;
  margin: 1.5rem 0;
  border-radius: 0 8px 8px 0;
  box-shadow: 0 1px 3px rgba(0,0,0,0.03);
}

.content :deep(.condition-block p) {
  margin-top: 0;
  color: #1e293b;
  font-weight: 600;
  margin-bottom: 0.75rem;
}

.content :deep(.condition-block ul) {
  margin: 0;
  padding-left: 1.25rem;
  color: #475569;
}

.content :deep(.condition-block li) {
  margin-bottom: 0.35rem;
}

.content :deep(blockquote) {
  border-left: 4px solid #3b82f6;
  background-color: #f8fafc;
  margin: 1.5rem 0;
  padding: 1rem 1.25rem;
  border-radius: 0 6px 6px 0;
  color: #1e3a8a;
}

.content :deep(blockquote p) {
  margin-bottom: 0.5rem;
}

.content :deep(blockquote p:last-child) {
  margin-bottom: 0;
}

.content :deep(p) {
  margin-bottom: 1.25rem;
}

.content :deep(img) {
  max-width: 100%;
  border-radius: 6px;
  margin: 1rem 0;
}

.content :deep(a) {
  color: var(--primary);
  text-decoration: underline;
}

/* Style Épuré des Tableaux avec Délimitation Nette des Colonnes */
.content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1.5rem 0;
  border: 1px solid #cbd5e1;
}

.content :deep(th),
.content :deep(td) {
  padding: 0.75rem 1rem;
  border: 1px solid #cbd5e1;
  text-align: left;
  vertical-align: top;
}

.content :deep(th) {
  background-color: #f1f5f9;
  color: #0f172a;
  font-weight: 600;
}

.content :deep(tr:nth-child(even)) {
  background-color: #f8fafc;
}

/* Mode Épuré / Lecture Simplifiée */
.simplified-reading {
  background-color: #faf9f5;
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.simplified-reading .content :deep(table) {
  background: white;
}

.simplified-reading .content :deep(th),
.simplified-reading .content :deep(td) {
  padding: 0.9rem 1.1rem;
}

.simplified-reading .content {
  font-size: 1.18rem;
  line-height: 1.9;
  letter-spacing: 0.03em;
  word-spacing: 0.06em;
  color: #1e293b;
}

.simplified-reading .content :deep(p) {
  margin-bottom: 1.75rem;
}

.simplified-reading .content :deep(h2) {
  background: white;
  border-left-width: 5px;
  padding: 0.75rem 1rem;
  margin-top: 3rem;
  margin-bottom: 1.5rem;
}

.simplified-reading .content :deep(.condition-block) {
  background: white;
  border: 1px solid #cbd5e1;
  border-left: 5px solid #334155;
  padding: 1.5rem;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.view-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.view-mode-tabs {
  display: flex;
  background: #f1f5f9;
  padding: 0.25rem;
  border-radius: 8px;
  border: 1px solid var(--border);
  gap: 0.25rem;
}

.tab-btn {
  padding: 0.4rem 0.8rem;
  border: none;
  background: transparent;
  border-radius: 6px;
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--text-muted);
  cursor: pointer;
  transition: all 0.15s ease;
}

.tab-btn:hover {
  color: var(--text-main);
  background: rgba(255, 255, 255, 0.6);
}

.tab-btn.active {
  background: white;
  color: var(--primary);
  font-weight: 600;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.simplified-btn {
  padding: 0.4rem 0.85rem;
  border: 1px solid #cbd5e1;
  background: white;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 500;
  color: #475569;
  cursor: pointer;
  transition: all 0.15s ease;
}

.simplified-btn:hover {
  background: #f8fafc;
  color: #1e293b;
  border-color: #94a3b8;
}

.simplified-btn.active {
  background: #334155;
  color: white;
  border-color: #334155;
  font-weight: 600;
}

.pdf-btn {
  padding: 0.4rem 0.85rem;
  border: 1px solid #0284c7;
  background: #0284c7;
  color: white;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s ease;
}

.pdf-btn:hover {
  background: #0369a1;
  border-color: #0369a1;
}

.diagram-column-full {
  width: 100%;
}

.diagram-full-card {
  background: white;
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.diagram-full-title {
  margin-top: 0;
  font-size: 1.3rem;
  color: var(--text-main);
  text-align: center;
  margin-bottom: 1.5rem;
}

.divider {
  border: 0;
  height: 1px;
  background: var(--border);
  margin: 4rem 0 2rem 0;
}

@media print {
  .breadcrumb,
  .view-controls,
  .sidebar-column,
  .divider,
  :deep(.community-suggestions),
  :deep(.suggestion-form-container),
  header nav,
  footer {
    display: none !important;
  }

  body, html {
    background: white !important;
    color: black !important;
    font-size: 9.5pt !important;
    line-height: 1.4 !important;
  }

  .proc-header {
    border-bottom: 2px solid #000;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
  }

  .proc-header h1 {
    font-size: 14pt !important;
    color: #000;
    margin-bottom: 0.25rem;
  }

  .meta {
    color: #333;
    font-size: 8.5pt !important;
  }

  .version {
    border: 1px solid #ccc;
    background: none;
    color: #000;
    padding: 0.1rem 0.35rem;
  }

  .layout-grid {
    display: block !important;
  }

  .main-column {
    width: 100% !important;
  }

  .content {
    font-size: 9.5pt !important;
    line-height: 1.4 !important;
  }

  .content :deep(h2) {
    font-size: 11pt !important;
    margin-top: 1rem !important;
    margin-bottom: 0.5rem !important;
    padding: 0.3rem 0.5rem !important;
  }

  .content :deep(h3) {
    font-size: 10pt !important;
    margin-top: 0.75rem !important;
    margin-bottom: 0.35rem !important;
  }

  .content :deep(p) {
    margin-bottom: 0.5rem !important;
  }

  .content :deep(table) {
    font-size: 9pt !important;
    page-break-inside: avoid;
    border: 1px solid #000 !important;
    margin: 0.75rem 0 !important;
  }

  .content :deep(th),
  .content :deep(td) {
    padding: 0.35rem 0.5rem !important;
    border: 1px solid #000 !important;
  }

  .content :deep(.condition-block) {
    font-size: 9pt !important;
    padding: 0.6rem 0.75rem !important;
    margin: 0.75rem 0 !important;
    page-break-inside: avoid;
    border: 1px solid #666 !important;
    border-left: 4px solid #000 !important;
    background: #f9f9f9 !important;
  }

  :deep(.mermaid-container) {
    page-break-before: always !important;
    break-before: page !important;
    page-break-inside: avoid !important;
    break-inside: avoid !important;
    page-break-after: avoid !important;
    break-after: avoid !important;
    max-width: 100% !important;
    margin-top: 0 !important;
    padding: 0 !important;
    border: none !important;
    background: transparent !important;
  }

  .diagram-full-card {
    border: none !important;
    box-shadow: none !important;
    padding: 0 !important;
  }

  .diagram-full-title {
    font-size: 12pt !important;
    margin-bottom: 0.5rem !important;
  }

  :deep(.mermaid) {
    display: flex !important;
    justify-content: center !important;
    align-items: center !important;
    max-width: 100% !important;
    overflow: visible !important;
  }

  :deep(.mermaid svg) {
    max-width: 100% !important;
    max-height: 88vh !important;
    height: auto !important;
    width: auto !important;
    margin: 0 auto !important;
  }
}
</style>
