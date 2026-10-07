import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { MotionPlugin } from 'motion-v'
import router from './router'
import App from './App.vue'
import './assets/style.css'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(MotionPlugin) // composant <Motion>, <AnimatePresence> et directive v-motion disponibles partout
app.mount('#app')
