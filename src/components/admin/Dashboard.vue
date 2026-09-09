<template>
  <div v-if="!authChecked" class="loading">Vérification de l'accès...</div>
  <div v-else class="dashboard">
    <header class="dash-header">
      <h1>Tableau de bord</h1>
      <div class="actions">
        <a :href="`${baseUrl}admin/editor`" class="btn">Créer une procédure</a>
        <a :href="`${baseUrl}admin/guide`" class="btn btn-secondary">Guide d'utilisation</a>
        <button @click="logout" class="btn btn-secondary">Déconnexion</button>
      </div>
    </header>

    <div class="stats-grid">
      <div class="card stat-card">
        <h3>Procédures</h3>
        <p class="stat-number">{{ procedures.length }}</p>
      </div>
      <div class="card stat-card">
        <h3>Suggestions à traiter</h3>
        <p class="stat-number">{{ suggestions.length }}</p>
      </div>
    </div>

    <h2 v-if="suggestions.length > 0">Suggestions en attente</h2>
    <div class="card list-card" v-if="suggestions.length > 0" style="margin-bottom: 3rem;">
      <table>
        <thead>
          <tr>
            <th>Votes</th>
            <th>Procédure</th>
            <th>Auteur</th>
            <th>Suggestion</th>
            <th>Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="sugg in suggestions" :key="sugg.id">
            <td class="font-medium text-orange">👍 {{ sugg.upvotes || 1 }}</td>
            <td class="font-medium">{{ getProcedureTitle(sugg.procedure_id) }}</td>
            <td>{{ sugg.author_name || 'Anonyme' }}</td>
            <td class="wrap-text">{{ sugg.content }}</td>
            <td class="nowrap">{{ new Date(sugg.created_at).toLocaleDateString() }}</td>
            <td class="nowrap">
              <button @click="markAsRead(sugg.id)" class="btn-small">✔ Traitée</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <h2>Dernières procédures</h2>
    <div class="card list-card">
      <table v-if="procedures.length > 0">
        <thead>
          <tr>
            <th>Titre</th>
            <th>Catégorie</th>
            <th>Version</th>
            <th>Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="proc in procedures" :key="proc.id">
            <td>{{ proc.title }}</td>
            <td>{{ getCategoryName(proc.category_id) }}</td>
            <td>v{{ proc.version }}</td>
            <td>{{ new Date(proc.updated_at).toLocaleDateString() }}</td>
            <td>
              <a :href="`${baseUrl}admin/editor?id=${proc.id}`" class="action-link">Éditer</a>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-else class="empty">Aucune procédure.</div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../../lib/supabase';

const baseUrl = import.meta.env.BASE_URL;
const authChecked = ref(false);
const procedures = ref([]);
const categories = ref([]);
const suggestions = ref([]);
// We might need to load all procedures to resolve titles for suggestions properly, but let's just use what we have or fetch missing ones
const allProceduresCache = ref([]);

onMounted(async () => {
  if (supabase.supabaseUrl !== 'https://placeholder.supabase.co') {
    const { data } = await supabase.auth.getSession();
    if (!data.session) {
      window.location.href = `${baseUrl}admin/login`;
      return;
    }
  }
  
  authChecked.value = true;
  await loadData();
});

const loadData = async () => {
  if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
    categories.value = [{ id: '1', name: 'Ressources Humaines' }];
    procedures.value = [
      { id: '101', title: 'Onboarding', category_id: '1', version: '1.2', updated_at: '2026-09-01T10:00:00Z' }
    ];
    allProceduresCache.value = procedures.value;
    suggestions.value = [{ id: '1', procedure_id: '101', author_name: 'Jean', content: 'Ajouter le lien vers le wiki', created_at: '2026-09-02T10:00:00Z' }];
    return;
  }

  const [cats, procs, suggs, allProcs] = await Promise.all([
    supabase.from('categories').select('*'),
    supabase.from('procedures').select('id, title, category_id, version, updated_at').order('updated_at', { ascending: false }),
    supabase.from('suggestions').select('*').eq('status', 'new').order('created_at', { ascending: false }),
    supabase.from('procedures').select('id, title') // Cache for mapping ID to title
  ]);
  
  if (cats.data) categories.value = cats.data;
  if (procs.data) procedures.value = procs.data;
  if (suggs.data) suggestions.value = suggs.data;
  if (allProcs.data) allProceduresCache.value = allProcs.data;
};

const getCategoryName = (id) => {
  const cat = categories.value.find(c => c.id == id);
  return cat ? cat.name : 'Inconnue';
};

const getProcedureTitle = (id) => {
  const proc = allProceduresCache.value.find(p => p.id === id);
  return proc ? proc.title : 'Procédure supprimée / Inconnue';
};

const markAsRead = async (id) => {
  if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
    suggestions.value = suggestions.value.filter(s => s.id !== id);
    return;
  }
  
  const { error } = await supabase.from('suggestions').update({ status: 'read' }).eq('id', id);
  if (!error) {
    suggestions.value = suggestions.value.filter(s => s.id !== id);
  } else {
    alert("Erreur lors de l'archivage.");
  }
};

const logout = async () => {
  await supabase.auth.signOut();
  window.location.href = `${baseUrl}admin/login`;
};
</script>

<style scoped>
.dash-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.actions {
  display: flex;
  gap: 1rem;
}

.btn-secondary {
  background-color: transparent;
  color: var(--text-muted);
  border: 1px solid var(--border);
}

.btn-secondary:hover {
  background-color: #f1f5f9;
  color: var(--text-main);
}

.btn-small {
  padding: 0.35rem 0.75rem;
  font-size: 0.85rem;
  background-color: #f1f5f9;
  color: #334155;
  border: 1px solid #cbd5e1;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.btn-small:hover {
  background-color: #10b981;
  color: white;
  border-color: #10b981;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.stat-card {
  text-align: center;
}

.stat-card h3 {
  color: var(--text-muted);
  font-size: 1rem;
  margin-top: 0;
}

.stat-number {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--primary);
  margin: 0;
}

.list-card {
  padding: 0;
  overflow: hidden;
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid var(--border);
}

th {
  background-color: #f8fafc;
  color: var(--text-muted);
  font-weight: 600;
  font-size: 0.875rem;
  text-transform: uppercase;
}

tr:last-child td {
  border-bottom: none;
}

.font-medium {
  font-weight: 500;
}

.wrap-text {
  max-width: 400px;
  white-space: normal;
  line-height: 1.4;
}

.nowrap {
  white-space: nowrap;
}

.text-orange {
  color: #f97316;
}

.action-link {
  color: var(--primary);
  text-decoration: none;
  font-weight: 500;
}

.action-link:hover {
  text-decoration: underline;
}

.empty {
  padding: 2rem;
  text-align: center;
  color: var(--text-muted);
}
</style>
