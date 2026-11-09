
import { useEffect, useState } from 'react'
import { api } from '../../api/client'

export default function MedicalRecords() {
    const [records, setRecords] = useState([])
    const [loading, setLoading] = useState(true)
    const [error, setError] = useState('')

    useEffect(() => {
        async function loadRecords() {
            try {
                const data = await api('/me/medical-records')
                setRecords(data)
            } catch (err) {
                setError('Could not load medical records.')
            } finally {
                setLoading(false)
            }
        }

        loadRecords()
    }, [])

    const visits = Object.values(
        records.reduce((groups, record) => {
            const id = record.appointmentID

            if (!groups[id]) {
                groups[id] = {
                    ...record,
                    diagnoses: [],
                    prescriptions: []
                }
            }

            if (
                record.diagnosis &&
                !groups[id].diagnoses.includes(record.diagnosis)
            ) {
                groups[id].diagnoses.push(record.diagnosis)
            }

            if (record.medicationName) {
                const prescription = {
                    name: record.medicationName,
                    dosage: record.dosage,
                    frequency: record.frequency,
                    duration: record.duration,
                    pharmacy: record.pharmacy
                }

                if (
                    !groups[id].prescriptions.some(
                        p => JSON.stringify(p) === JSON.stringify(prescription)
                    )
                ) {
                    groups[id].prescriptions.push(prescription)
                }
            }

            return groups
        }, {})
    )

    if (loading) return <p>Loading medical records...</p>
    if (error) return <p role="alert">{error}</p>

    return (
        <div className="page">
            <h2>Medical Records</h2>
            <p>View your past visits, diagnoses, and prescriptions.</p>

            {visits.length === 0 ? (
                <p>No medical records available.</p>
            ) : (
                visits.map(visit => (
                    <div className="card" key={visit.appointmentID}>
                        <h3>
                            {new Date(visit.visitDate).toLocaleDateString()}
                        </h3>

                        <p><strong>Doctor:</strong> {visit.doctorName}</p>
                        <p><strong>Reason for visit:</strong> {visit.visitReason || 'Not provided'}</p>

                        <h4>Diagnoses</h4>
                        {visit.diagnoses.length ? (
                            visit.diagnoses.map((d, i) => <p key={i}>{d}</p>)
                        ) : (
                            <p>No diagnoses recorded.</p>
                        )}

                        <h4>Prescriptions</h4>
                        {visit.prescriptions.length ? (
                            visit.prescriptions.map((p, i) => (
                                <div key={i}>
                                    <p><strong>Medication:</strong> {p.name}</p>
                                    <p><strong>Dosage:</strong> {p.dosage || 'N/A'}</p>
                                    <p><strong>Frequency:</strong> {p.frequency || 'N/A'}</p>
                                    <p><strong>Duration:</strong> {p.duration || 'N/A'}</p>
                                    <p><strong>Pharmacy:</strong> {p.pharmacy || 'N/A'}</p>
                                </div>
                            ))
                        ) : (
                            <p>No prescriptions recorded.</p>
                        )}

                        <p><strong>Treatment plan:</strong> {visit.treatmentPlan || 'N/A'}</p>
                        <p><strong>Follow-up:</strong> {visit.followUp || 'N/A'}</p>
                    </div>
                ))
            )}
        </div>
    )
}
