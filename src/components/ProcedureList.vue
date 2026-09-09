<template>
  <div>
    <div class="breadcrumb">
      <a :href="baseUrl">← Retour aux catégories</a>
    </div>
    
    <div v-if="loading" class="loading">Chargement des procédures...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else>
      <h1 class="page-title">{{ categoryName }}</h1>
      
      <div class="list">
        <a v-for="proc in procedures" :key="proc.id" :href="`${baseUrl}procedure?id=${proc.id}`" class="card procedure-card">
          <div class="proc-header">
            <h2>{{ proc.title }}</h2>
            <span class="version">v{{ proc.version || '1.0' }}</span>
          </div>
          <p class="date">Mise à jour: {{ new Date(proc.updated_at).toLocaleDateString() }}</p>
        </a>
        <div v-if="procedures.length === 0" class="empty">
          Aucune procédure dans cette catégorie.
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../lib/supabase';

const baseUrl = import.meta.env.BASE_URL;
const procedures = ref([]);
const categoryName = ref('Catégorie');
const loading = ref(true);
const error = ref('');

onMounted(async () => {
  const urlParams = new URLSearchParams(window.location.search);
  const categoryId = urlParams.get('id');
  
  if (!categoryId) {
    error.value = "Identifiant de catégorie manquant.";
    loading.value = false;
    return;
  }

  try {
    if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
      setTimeout(() => {
        categoryName.value = categoryId === '1' ? 'Ressources Humaines' : 'Catégorie ' + categoryId;
        procedures.value = [
          { id: '101', title: 'Onboarding nouveau collaborateur', version: '1.2', updated_at: '2026-09-01T10:00:00Z' },
          { id: '102', title: 'Demande de congés', version: '2.0', updated_at: '2026-08-15T10:00:00Z' }
        ];
        loading.value = false;
      }, 500);
      return;
    }

    // Fetch category name
    const { data: catData } = await supabase.from('categories').select('name').eq('id', categoryId).single();
    if (catData) categoryName.value = catData.name;

    // Fetch procedures
    const { data, error: dbError } = await supabase
      .from('procedures')
      .select('id, title, version, updated_at')
      .eq('category_id', categoryId)
      .order('updated_at', { ascending: false });
      
    if (dbError) throw dbError;
    procedures.value = data || [];
  } catch (e) {
    console.error(e);
    error.value = "Impossible de charger les procédures.";
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

.page-title {
  margin-bottom: 2rem;
  font-size: 2rem;
  color: var(--text-main);
}

.list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.procedure-card {
  text-decoration: none;
  color: inherit;
  display: block;
  transition: all 0.2s ease;
}

.procedure-card:hover {
  border-color: var(--primary);
  background-color: #f8fafc;
}

.proc-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.proc-header h2 {
  font-size: 1.25rem;
  color: var(--text-main);
  margin: 0;
}

.version {
  background-color: #e0f2fe;
  color: #0369a1;
  padding: 0.25rem 0.5rem;
  border-radius: 9999px;
  font-size: 0.8rem;
  font-weight: 600;
}

.date {
  color: var(--text-muted);
  font-size: 0.875rem;
  margin: 0;
}
</style>
