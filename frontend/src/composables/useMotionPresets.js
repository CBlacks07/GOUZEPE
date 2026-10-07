// Réglages Motion partagés : on les réutilise partout pour garder un mouvement cohérent sur tout le site.
//   <Motion v-bind="fadeUp" />   |   <Motion v-bind="fadeUp" :transition="stagger(i)" />
export const spring = { type: 'spring', stiffness: 260, damping: 28 }
export const ease = { duration: 0.35, ease: [0.22, 1, 0.36, 1] }

// Retard progressif pour les listes (i = index de l'élément)
export const stagger = (i, step = 0.05, max = 0.6) => ({ ...ease, delay: Math.min(i * step, max) })

// Apparition simple (montée + fondu), déclenchée à l'affichage
export const fadeUp = {
  initial: { opacity: 0, y: 14 },
  animate: { opacity: 1, y: 0 },
  transition: ease,
}

// Apparition au défilement de la page (une seule fois)
export const revealOnScroll = {
  initial: { opacity: 0, y: 22 },
  whileInView: { opacity: 1, y: 0 },
  inViewOptions: { once: true, amount: 0.2 },
  transition: ease,
}

// Interactions des boutons / cartes cliquables
export const press = { whileHover: { y: -2 }, whileTap: { scale: 0.97 } }
