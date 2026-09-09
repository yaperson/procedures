<template>
  <div>
    <div v-if="loading" class="loading">Chargement des catégories...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <div v-else class="grid">
      <a v-for="cat in categories" :key="cat.id" :href="`${baseUrl}category?id=${cat.id}`" class="card category-card">
        <h2>{{ cat.name }}</h2>
        <p>{{ cat.description }}</p>
      </a>
      <div v-if="categories.length === 0" class="empty">
        Aucune catégorie n'est encore disponible.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../lib/supabase';

const baseUrl = import.meta.env.BASE_URL;
const categories = ref([]);
const loading = ref(true);
const error = ref('');

onMounted(async () => {
  try {
    // If Supabase is not configured, load mock data
    if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
      setTimeout(() => {
        categories.value = [
          { id: '1', name: 'Ressources Humaines', description: 'Procédures d\'accueil, congés...' },
          { id: '2', name: 'Informatique', description: 'Configuration, sécurité...' },
          { id: '3', name: 'Ventes', description: 'Processus de prospection et conclusion' }
        ];
        loading.value = false;
      }, 500);
      return;
    }

    const { data, error: dbError } = await supabase
      .from('categories')
      .select('*')
      .order('name');
      
    if (dbError) throw dbError;
    categories.value = data || [];
  } catch (e) {
    console.error(e);
    error.value = "Impossible de charger les catégories.";
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1.5rem;
}

.category-card {
  text-decoration: none;
  color: inherit;
  transition: transform 0.2s, box-shadow 0.2s;
  display: block;
}

.category-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  border-color: var(--primary);
}

.category-card h2 {
  color: var(--primary);
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
}

.category-card p {
  color: var(--text-muted);
  font-size: 0.95rem;
}

.loading, .error, .empty {
  text-align: center;
  padding: 3rem;
  color: var(--text-muted);
}
</style>
