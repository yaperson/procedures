<template>
  <div class="community-suggestions">
    <h3>Idées & Suggestions</h3>
    
    <div class="suggestions-list" v-if="suggestions.length > 0">
      <div v-for="sugg in suggestions" :key="sugg.id" class="suggestion-item">
        <div class="vote-column">
          <button 
            @click="upvote(sugg)" 
            class="upvote-btn" 
            :class="{ 'voted': votedIds.includes(sugg.id) }"
            :disabled="votedIds.includes(sugg.id)"
            title="Voter pour cette idée"
          >
            ▲
          </button>
          <span class="score">{{ sugg.upvotes || 1 }}</span>
        </div>
        <div class="sugg-content">
          <p class="text">{{ sugg.content }}</p>
          <span class="meta">Proposé par {{ sugg.author_name || 'Anonyme' }} le {{ new Date(sugg.created_at).toLocaleDateString() }}</span>
        </div>
      </div>
    </div>
    <div v-else class="empty-msg">
      Aucune suggestion pour le moment. Soyez le premier à proposer une amélioration !
    </div>

    <div class="suggestion-box">
      <h4>Proposer une nouvelle amélioration</h4>
      
      <div v-if="success" class="success-message">
        Merci pour votre suggestion ! Elle a bien été envoyée et sera visible par les autres.
      </div>
      
      <form v-else @submit.prevent="submitSuggestion">
        <div class="form-group">
          <label for="name">Votre nom (optionnel)</label>
          <input type="text" id="name" v-model="form.name" placeholder="Ex: Jean Dupont" />
        </div>
        
        <div class="form-group">
          <label for="suggestion">Votre suggestion *</label>
          <textarea 
            id="suggestion" 
            v-model="form.suggestion" 
            rows="3" 
            required
            placeholder="Décrivez ce qui pourrait être amélioré dans cette procédure..."
          ></textarea>
        </div>
        
        <button type="submit" :disabled="loading" class="btn-submit">
          <span v-if="loading">Envoi...</span>
          <span v-else>Envoyer la suggestion</span>
        </button>
        
        <div v-if="error" class="error-message">
          {{ error }}
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../lib/supabase';

const props = defineProps({
  procedureId: {
    type: String,
    required: true
  }
});

const form = ref({
  name: '',
  suggestion: ''
});

const suggestions = ref([]);
const votedIds = ref([]);

const loading = ref(false);
const success = ref(false);
const error = ref('');

onMounted(async () => {
  // Load voted IDs from local storage
  const stored = localStorage.getItem('voted_suggestions');
  if (stored) {
    try {
      votedIds.value = JSON.parse(stored);
    } catch (e) {}
  }
  
  await loadSuggestions();
});

const loadSuggestions = async () => {
  if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
    suggestions.value = [
      { id: '1', content: 'Ajouter une vidéo explicative à l\'étape 2.', author_name: 'Alice', upvotes: 12, created_at: new Date().toISOString() },
      { id: '2', content: 'Le lien vers le formulaire RH est mort, il faudrait le mettre à jour.', author_name: 'Bob', upvotes: 5, created_at: new Date().toISOString() }
    ];
    return;
  }
  
  const { data, error } = await supabase
    .from('suggestions')
    .select('*')
    .eq('procedure_id', props.procedureId)
    .eq('status', 'new')
    .order('upvotes', { ascending: false });
    
  if (data) {
    suggestions.value = data;
  }
};

const upvote = async (sugg) => {
  if (votedIds.value.includes(sugg.id)) return;
  
  const newScore = (sugg.upvotes || 1) + 1;
  sugg.upvotes = newScore;
  
  votedIds.value.push(sugg.id);
  localStorage.setItem('voted_suggestions', JSON.stringify(votedIds.value));
  
  if (supabase.supabaseUrl !== 'https://placeholder.supabase.co') {
    await supabase.from('suggestions').update({ upvotes: newScore }).eq('id', sugg.id);
  }
  
  // Re-sort suggestions client-side
  suggestions.value.sort((a, b) => (b.upvotes || 1) - (a.upvotes || 1));
};

const submitSuggestion = async () => {
  loading.value = true;
  error.value = '';
  
  try {
    const payload = { 
      procedure_id: props.procedureId, 
      author_name: form.value.name,
      content: form.value.suggestion,
      upvotes: 1
    };
    
    if (supabase.supabaseUrl !== 'https://placeholder.supabase.co') {
      const { data, error: dbError } = await supabase
        .from('suggestions')
        .insert([payload])
        .select()
        .single();
        
      if (dbError) throw dbError;
      if (data) {
        suggestions.value.push(data);
        votedIds.value.push(data.id);
        localStorage.setItem('voted_suggestions', JSON.stringify(votedIds.value));
      }
    } else {
      suggestions.value.push({
        id: Math.random().toString(),
        ...payload,
        created_at: new Date().toISOString()
      });
    }
    
    // Sort array
    suggestions.value.sort((a, b) => (b.upvotes || 1) - (a.upvotes || 1));
    
    success.value = true;
    form.value.name = '';
    form.value.suggestion = '';
    
    // Reset success msg after 5s so they can post again if they want
    setTimeout(() => {
      success.value = false;
    }, 5000);
  } catch (e) {
    console.error(e);
    error.value = "Une erreur s'est produite lors de l'envoi. Veuillez réessayer.";
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.community-suggestions {
  margin: 3rem 0;
  border-top: 2px solid #e2e8f0;
  padding-top: 2rem;
}

.community-suggestions h3 {
  font-size: 1.5rem;
  color: #1e293b;
  margin-bottom: 1.5rem;
  margin-top: 0;
}

.empty-msg {
  color: #64748b;
  font-style: italic;
  margin-bottom: 2rem;
}

.suggestions-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 2.5rem;
}

.suggestion-item {
  display: flex;
  gap: 1rem;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.vote-column {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  min-width: 40px;
}

.upvote-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #94a3b8;
  cursor: pointer;
  padding: 0;
  line-height: 1;
  transition: color 0.2s;
}

.upvote-btn:hover:not(:disabled) {
  color: #f97316; /* Reddit orange */
}

.upvote-btn.voted {
  color: #f97316;
  cursor: default;
}

.score {
  font-weight: bold;
  font-size: 1.1rem;
  color: #334155;
  margin-top: 0.25rem;
}

.sugg-content {
  flex: 1;
}

.sugg-content .text {
  margin: 0 0 0.5rem 0;
  color: #1e293b;
  line-height: 1.5;
}

.sugg-content .meta {
  font-size: 0.8rem;
  color: #64748b;
}

.suggestion-box {
  padding: 1.5rem;
  background-color: #f8fafc;
  border-radius: 8px;
  border: 1px dashed #cbd5e1;
}

.suggestion-box h4 {
  margin-top: 0;
  color: #334155;
  font-size: 1.1rem;
  margin-bottom: 1rem;
}

.form-group {
  margin-bottom: 1rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #475569;
  font-size: 0.9rem;
}

input[type="text"],
textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  font-family: inherit;
  font-size: 1rem;
  background-color: white;
  transition: border-color 0.2s ease;
  box-sizing: border-box;
}

input[type="text"]:focus,
textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.btn-submit {
  background-color: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.btn-submit:hover:not(:disabled) {
  background-color: #2563eb;
}

.btn-submit:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.success-message {
  padding: 1rem;
  background-color: #dcfce7;
  color: #166534;
  border-radius: 6px;
  text-align: center;
  font-weight: 500;
}

.error-message {
  margin-top: 1rem;
  color: #ef4444;
  font-size: 0.9rem;
}
</style>
