<template>
  <div class="login-container">
    <div class="card login-card">
      <h2>Connexion Administrateur</h2>
      <p class="subtitle">Connectez-vous pour gérer les procédures</p>
      
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label for="email">Email</label>
          <input type="email" id="email" v-model="email" required />
        </div>
        
        <div class="form-group">
          <label for="password">Mot de passe</label>
          <input type="password" id="password" v-model="password" required />
        </div>
        
        <button type="submit" class="btn btn-primary" :disabled="loading">
          {{ loading ? 'Connexion...' : 'Se connecter' }}
        </button>
        
        <div v-if="error" class="error">{{ error }}</div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../../lib/supabase';

const baseUrl = import.meta.env.BASE_URL;
const email = ref('');
const password = ref('');
const loading = ref(false);
const error = ref('');

onMounted(async () => {
  const { data } = await supabase.auth.getSession();
  if (data.session) {
    window.location.href = `${baseUrl}admin/dashboard/`;
  }
});

const handleLogin = async () => {
  loading.value = true;
  error.value = '';
  
  if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
    // Mock login for preview
    setTimeout(() => {
      window.location.href = `${baseUrl}admin/dashboard/`;
    }, 1000);
    return;
  }
  
  try {
    const { error: authError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    });
    
    if (authError) throw authError;
    
    window.location.href = `${baseUrl}admin/dashboard/`;
  } catch (e) {
    error.value = "Identifiants invalides.";
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
}

.login-card {
  width: 100%;
  max-width: 400px;
  padding: 2rem;
}

h2 {
  margin-top: 0;
  color: var(--text-main);
  text-align: center;
}

.subtitle {
  text-align: center;
  color: var(--text-muted);
  margin-bottom: 2rem;
  font-size: 0.9rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  font-size: 0.9rem;
}

input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid var(--border);
  border-radius: 6px;
  font-family: inherit;
  font-size: 1rem;
}

input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.btn-primary {
  width: 100%;
}

.error {
  margin-top: 1rem;
  color: #ef4444;
  text-align: center;
  font-size: 0.9rem;
}
</style>
