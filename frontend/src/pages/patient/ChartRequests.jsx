
import { useEffect, useState } from 'react'
import { api } from '../../api/client'

export default function ChartRequests() {
    const [requests, setRequests] = useState([])
    const [doctors, setDoctors] = useState([])
    const [doctorId, setDoctorId] = useState('')
    const [loading, setLoading] = useState(true)
    const [submitting, setSubmitting] = useState(false)
    const [message, setMessage] = useState('')
    const [error, setError] = useState('')

    async function loadRequests() {
        const data = await api('/me/chart-requests')
        setRequests(data)
    }

    useEffect(() => {
        async function load() {
            try {
                const [requestData, doctorData] = await Promise.all([
                    api('/me/chart-requests'),
                    api('/me/doctors')
                ])
                setRequests(requestData)
                setDoctors(doctorData)
            } catch {
                setError('Could not load chart requests.')
            } finally {
                setLoading(false)
            }
        }

        load()
    }, [])

    async function submitRequest(e) {
        e.preventDefault()
        if (!doctorId || submitting) return

        setSubmitting(true)
        setMessage('')
        setError('')

        try {
            await api('/me/chart-requests', {
                method: 'POST',
                body: JSON.stringify({ doctorID: Number(doctorId) })
            })

            await loadRequests()
            setDoctorId('')
            setMessage('Chart request submitted successfully.')
        } catch {
            setError('Could not submit chart request.')
        } finally {
            setSubmitting(false)
        }
    }

    return (
        <div className="page">
            <h2>Request Medical Chart</h2>
            <p>Request a copy of your medical chart from your doctor.</p>

            <div className="card">
                <h3>New chart request</h3>

                <form onSubmit={submitRequest}>
                    <label htmlFor="chart-doctor">Select doctor</label>

                    <select
                        id="chart-doctor"
                        value={doctorId}
                        onChange={e => setDoctorId(e.target.value)}
                        required
                    >
                        <option value="">Choose a doctor</option>
                        {doctors.map(doctor => (
                            <option
                                key={doctor.doctorID}
                                value={doctor.doctorID}
                            >
                                {doctor.doctorName}
                            </option>
                        ))}
                    </select>

                    <button type="submit" disabled={submitting || !doctorId}>
                        {submitting ? 'Submitting...' : 'Request chart'}
                    </button>
                </form>

                {message && <p role="status">{message}</p>}
                {error && <p role="alert">{error}</p>}
            </div>

            <div className="card">
                <h3>My chart requests</h3>

                {loading ? (
                    <p>Loading requests...</p>
                ) : requests.length === 0 ? (
                    <p>You have no chart requests yet.</p>
                ) : (
                    requests.map(request => (
                        <div key={request.requestID}>
                            <p><strong>Doctor:</strong> {request.doctorName}</p>
                            <p>
                                <strong>Requested:</strong>{' '}
                                {new Date(request.requestDate).toLocaleDateString()}
                            </p>
                            <p>
                                <strong>Status:</strong> {request.requestStatus}
                            </p>
                            <hr />
                        </div>
                    ))
                )}
            </div>
        </div>
    )
}
