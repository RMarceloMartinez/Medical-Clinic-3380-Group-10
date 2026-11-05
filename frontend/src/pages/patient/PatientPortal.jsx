import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import Icon from '../../components/Icon'
import Layout from '../../components/Layout'
import MyAppointments from './MyAppointments'
import BookAppointment from './BookAppointment'
import MyBalance from './MyBalance'
import { Navigate, useNavigate, useParams } from 'react-router'

// The patient side of the app. Every page here calls /api/me/...,
// which only ever returns the logged-in patient's own data.
const PAGES = [
  { key: 'home', icon: 'home', label: 'Home' },
  { key: 'appointments', icon: 'calendar', label: 'My appointments' },
  { key: 'book', icon: 'calendarPlus', label: 'Book appointment' },
  { key: 'balance', icon: 'wallet', label: 'My balance' },
]

export default function PatientPortal({ account, onLogout }) {
  // The page comes from the address: /portal -> home, /portal/book -> book
  const { page = 'home' } = useParams()
  const navigate = useNavigate()
  const setPage = (key) => navigate(key === 'home' ? '/portal' : `/portal/${key}`)

  if (!PAGES.some((p) => p.key === page)) {
    return <Navigate to="/portal" replace />
  }

  function renderPage() {
    switch (page) {
      case 'appointments': return <MyAppointments onBook={() => setPage('book')} />
      case 'book': return <BookAppointment onBooked={() => setPage('appointments')} />
      case 'balance': return <MyBalance />
      default: return <PatientHome account={account} onOpen={setPage} />
    }
  }

  return (
    <Layout
      title="Patient portal"
      account={account}
      items={PAGES}
      current={page}
      onSelect={setPage}
      onLogout={onLogout}
    >
      <div key={page}>{renderPage()}</div>
    </Layout>
  )
}

function formatDateTime(value) {
  return new Date(value).toLocaleString([], { dateStyle: 'full', timeStyle: 'short' })
}

// Home: next visit + balance at a glance, and shortcuts to the other pages
function PatientHome({ account, onOpen }) {
  const [next, setNext] = useState(undefined)      // undefined = loading, null = none
  const [balance, setBalance] = useState(null)
  const [error, setError] = useState('')

  useEffect(() => {
    async function load() {
      try {
        const [appointments, myBalance] = await Promise.all([
          api.get('/me/appointments'),
          api.get('/me/balance'),
        ])
        const now = new Date()
        const upcoming = appointments
          .filter((a) => a.appointStatus === 'Scheduled' && new Date(a.appointmentDateTime) >= now)
          .sort((x, y) => new Date(x.appointmentDateTime) - new Date(y.appointmentDateTime))
        setNext(upcoming[0] ?? null)
        setBalance(myBalance)
      } catch (e) {
        setError(e.message)
      }
    }
    load()
  }, [])

  return (
    <div className="home">
      <div className="welcome-banner">
        <div>
          <h2>Welcome back, {account.username}</h2>
          <p>Your visits and bills, all in one place.</p>
        </div>
        <button type="button" className="primary-button" onClick={() => onOpen('book')}>
          Book an appointment
        </button>
      </div>

      {error && <p className="error-message">{error}</p>}

      <div className="home-cards">
        <div className="info-card">
          <span className="home-card-title">Next appointment</span>
          {next === undefined && <span className="home-card-text">Loading…</span>}
          {next === null && <span className="home-card-text">You have no upcoming appointments.</span>}
          {next && (
            <span className="home-card-text">
              <strong>{formatDateTime(next.appointmentDateTime)}</strong><br />
              with {next.doctorName}<br />
              {next.officeAddress}
            </span>
          )}
        </div>

        <div className="info-card">
          <span className="home-card-title">Balance due</span>
          <span className="home-card-text big-number">
            {balance ? `$${Number(balance.balance).toFixed(2)}` : '…'}
          </span>
        </div>
      </div>

      <h3 className="home-section-title">Quick links</h3>
      <div className="home-cards">
        <button type="button" className="home-card" onClick={() => onOpen('book')}>
          <span className="icon-circle orange"><Icon name="calendarPlus" size={24} /></span>
          <span className="home-card-title">Book an appointment</span>
          <span className="home-card-text">See your doctors and pick a day and time.</span>
        </button>
        <button type="button" className="home-card" onClick={() => onOpen('appointments')}>
          <span className="icon-circle"><Icon name="calendar" size={24} /></span>
          <span className="home-card-title">My appointments</span>
          <span className="home-card-text">See upcoming and past visits, or cancel one.</span>
        </button>
        <button type="button" className="home-card" onClick={() => onOpen('balance')}>
          <span className="icon-circle"><Icon name="wallet" size={24} /></span>
          <span className="home-card-title">My balance</span>
          <span className="home-card-text">What you have been billed and paid.</span>
        </button>
      </div>
    </div>
  )
}
