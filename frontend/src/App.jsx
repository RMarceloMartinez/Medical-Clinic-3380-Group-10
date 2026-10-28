import { useEffect, useState } from 'react'
import './App.css'
import { api, setUnauthorizedHandler } from './api'
import Login from './Login'
import SignUp from './SignUp'
import PatientPortal from './PatientPortal'
import StaffDashboard from './StaffDashboard'

// The app's front door. It only decides WHICH part of the app to show:
//   not logged in -> Login or SignUp
//   Patient       -> PatientPortal (their own pages only)
//   staff roles   -> StaffDashboard (menu depends on the role)
export default function App() {
  const [account, setAccount] = useState(null)        // { username, role, ... } or null
  const [screen, setScreen] = useState('login')       // 'login' | 'signup' (only while logged out)
  const [checking, setChecking] = useState(true)      // true while we ask the API "am I logged in?"
  const [notice, setNotice] = useState('')            // message shown on the login card

  useEffect(() => {
    // Any 401 from a page = the login expired -> back to the login screen
    setUnauthorizedHandler(() => {
      setAccount(null)
      setScreen('login')
      setNotice('Your session ended. Please log in again.')
    })

    // After a page reload the cookie is still there, so ask who is logged in
    api.me()
      .then((me) => setAccount(me))
      .catch(() => setAccount(null))
      .finally(() => setChecking(false))
  }, [])

  function handleLoggedIn(loggedInAccount) {
    setNotice('')
    setAccount(loggedInAccount)
  }

  async function handleLogout() {
    try {
      await api.logout()
    } catch (error) {
      console.error('Logout request failed:', error)
    }
    setAccount(null)
    setScreen('login')
    setNotice('')
  }

  if (checking) {
    return <div className="Login-screen"><p className="loading-text">Loading…</p></div>
  }

  if (!account) {
    return screen === 'signup'
      ? <SignUp onLoggedIn={handleLoggedIn} onBack={() => setScreen('login')} />
      : <Login onLoggedIn={handleLoggedIn} onSignUp={() => { setNotice(''); setScreen('signup') }} notice={notice} />
  }

  if (account.role === 'Patient') {
    return <PatientPortal account={account} onLogout={handleLogout} />
  }

  return <StaffDashboard account={account} onLogout={handleLogout} />
}
