// Source unique de la navigation de l'espace connecté.
// Header, menu mobile, barre latérale admin et tableau de bord admin lisent
// tous ces listes : ne pas redéfinir de liens ailleurs.
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import {
  HomeIcon, CalendarDaysIcon, SwordsIcon, BarChart2Icon, TrophyIcon, GamepadIcon,
  LayoutDashboardIcon, UsersIcon, ShieldIcon, MegaphoneIcon, PaletteIcon, DatabaseIcon,
  ListOrderedIcon, FolderClockIcon,
} from 'lucide-vue-next'

export const EFOOT_LINKS = [
  { to: '/accueil',    label: 'Accueil',    icon: HomeIcon },
  { to: '/journees',   label: 'Journées',   icon: CalendarDaysIcon },
  { to: '/duel',       label: 'Duels',      icon: SwordsIcon },
  { to: '/classement', label: 'Classement', icon: BarChart2Icon },
  { to: '/tournois',   label: 'Tournois',   icon: TrophyIcon },
]

export const TEKKEN_LINKS = [
  { to: '/accueil-tekken',  label: 'Accueil',  icon: HomeIcon },
  { to: '/tekken-ladder',   label: 'Ladder',   icon: ListOrderedIcon },
  { to: '/tekken-tournois', label: 'Tournois', icon: TrophyIcon },
]

export const ADMIN_HOME = { to: '/admin', label: 'Tableau de bord', icon: LayoutDashboardIcon }

export const ADMIN_GROUPS = [
  {
    key: 'efoot', title: 'eFootball', links: [
      { to: '/admin/journees', label: 'Journées',  desc: 'Saisir, publier et corriger les journées', icon: CalendarDaysIcon },
      { to: '/admin/saisons',  label: 'Saisons',   desc: 'Créer une saison, gérer les journées confirmées', icon: FolderClockIcon },
      { to: '/admin/tournois', label: 'Tournois',  desc: 'Créer et gérer les tournois eFoot', icon: TrophyIcon },
      { to: '/admin/joueurs',  label: 'Joueurs',   desc: 'Gérer les joueurs du club', icon: UsersIcon },
    ],
  },
  {
    key: 'tekken', title: 'Tekken', links: [
      { to: '/admin/tekken/journees', label: 'Journées',       desc: 'Journées de championnat : scores, points, ELO', icon: CalendarDaysIcon },
      { to: '/admin/tekken',          label: 'Ladder & duels', desc: 'Classement ELO et duels classés', icon: SwordsIcon },
      { to: '/admin/tekken/tournois', label: 'Tournois',       desc: 'Tournois Tekken', icon: GamepadIcon },
    ],
  },
  {
    key: 'club', title: 'Club', links: [
      { to: '/admin/utilisateurs', label: 'Utilisateurs', desc: "Comptes et demandes d'adhésion", icon: ShieldIcon, badge: 'membership' },
      { to: '/admin/news',         label: 'Actualités',   desc: 'Annonces du club', icon: MegaphoneIcon },
      { to: '/admin/site',         label: 'Apparence',    desc: 'Textes, logo, fond, couleurs', icon: PaletteIcon },
      { to: '/admin/sauvegardes',  label: 'Sauvegardes',  desc: 'Backups et restauration', icon: DatabaseIcon },
    ],
  },
]

// Le lien actif est le plus long préfixe correspondant, pour que
// /admin/tekken ne s'allume pas sur /admin/tekken/tournois.
export function bestMatch(path, links) {
  let best = null
  for (const l of links) {
    const hit = path === l.to || path.startsWith(l.to + '/')
    if (hit && (!best || l.to.length > best.to.length)) best = l
  }
  return best
}

export function useMemberNav() {
  const auth = useAuthStore()
  const mg = computed(() => auth.mainGame || 'efoot')
  // L'admin gère les deux pôles : il voit toujours les deux.
  const showEfoot  = computed(() => auth.isAdmin || mg.value === 'efoot' || mg.value === 'both')
  const showTekken = computed(() => auth.isAdmin || mg.value === 'tekken' || mg.value === 'both')
  const homeRoute  = computed(() => (auth.isAdmin ? '/admin' : '/profil'))
  return { showEfoot, showTekken, homeRoute }
}
