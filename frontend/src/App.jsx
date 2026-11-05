import { useEffect, useState } from 'react'
import { Navigate, Route, Routes, useLocation, useNavigate } from 'react-router'
import './styles/App.css'
import { api, setUnauthorizedHandler } from './api/client'
import Login from './pages/auth/Login'
import SignUp from './pages/auth/SignUp'
import PatientPortal from './pages/patient/PatientPortal'
import StaffDashboard from './pages/staff/StaffDashboard'

// The app's front door: which address shows which part of the app.
//   /                  login           /signup            new patient account
//   /portal/:page?     patients only   /staff/:section?   staff roles only
// Addresses inside the portals are protected: logged out -> back to login
// (and back to that page after logging in); wrong role -> your own home.
export default function App() {
  const [account, setAccount] = useState(null)        // { username, role, ... } or null
  const [checking, setChecking] = useState(true)      // true while we ask the API "am I logged in?"
  const [notice, setNotice] = useState('')            // message shown on the login card
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    // Any 401 from a page = the login expired -> back to the login screen
    setUnauthorizedHandler(() => {
      setAccount(null)
      setNotice('Your session ended. Please log in again.')
      navigate('/', { replace: true })
    })

    // After a page reload the cookie is still there, so ask who is logged in
    api.me()
      .then((me) => setAccount(me))
      .catch(() => setAccount(null))
      .finally(() => setChecking(false))
  }, [navigate])

  // Where each role starts
  const homeFor = (acc) => (acc.role === 'Patient' ? '/portal' : '/staff')

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
    setNotice('')
    navigate('/')
  }

  // Protected route: only show `page` to a logged-in user whose role `fits`
  function guard(fits, page) {
    if (!account) return <Navigate to="/" replace state={{ from: location.pathname }} />
    if (!fits) return <Navigate to={homeFor(account)} replace />
    return page
  }

  if (checking) {
    return <p className="loading-text">Loading…</p>
  }

  return (
    <Routes>
      <Route
        path="/"
        element={account
        ? <Navigate to={location.state?.from ?? homeFor(account)} replace />
          : <Login onLoggedIn={handleLoggedIn} onSignUp={() => { setNotice(''); navigate('/signup') }} notice={notice} />}
      />
      <Route
        path="/signup"
        element={account
          ? <Navigate to={homeFor(account)} replace />
          : <SignUp onLoggedIn={handleLoggedIn} onBack={() => navigate('/')} />}
      />
      <Route
        path="/portal/:page?"
        element={guard(account?.role === 'Patient', <PatientPortal account={account} onLogout={handleLogout} />)}
      />
      <Route
        path="/staff/:section?"
        element={guard(account && account.role !== 'Patient', <StaffDashboard account={account} onLogout={handleLogout} />)}
      />
      {/* Any other address: back to the start */}
      <Route path="*" element={<Navigate to={account ? homeFor(account) : '/'} replace />} />
    </Routes>
  )
}