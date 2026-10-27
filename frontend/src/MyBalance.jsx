import { useEffect, useState } from 'react'
import { api } from './api'

// The logged-in patient's balance (query Q2 run with their own ID)
export default function MyBalance() {
  const [balance, setBalance] = useState(null)
  const [error, setError] = useState('')

  useEffect(() => {
    api.get('/me/balance')
      .then(setBalance)
      .catch((e) => setError(e.message))
  }, [])

  const money = (n) => `$${Number(n).toFixed(2)}`

  return (
    <div className="panel">
      <h2>My balance</h2>
      {error && <p className="error-message">{error}</p>}
      {!balance && !error && <p>Loading…</p>}
      {balance && (
        <>
          <table className="data-table balance-table">
            <tbody>
              <tr><th>Billed for completed visits</th><td>{money(balance.billed)}</td></tr>
              <tr><th>Paid</th><td>{money(balance.paid)}</td></tr>
              <tr className="balance-total"><th>Balance due</th><td>{money(balance.balance)}</td></tr>
            </tbody>
          </table>
          <p className="field-hint">
            {Number(balance.balance) > 0
              ? 'You can pay at the front desk or call the clinic.'
              : 'You are all paid up. Thank you!'}
          </p>
        </>
      )}
    </div>
  )
}
