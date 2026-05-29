import { useState } from 'react';
import { motion } from 'motion/react';
import { AlertTriangle, MapPin, Clock } from 'lucide-react';
import { Screen, Violation } from '../App';

interface ViolationsListScreenProps {
  navigateTo: (screen: Screen, data?: any) => void;
}

const mockViolations: Violation[] = [
  {
    id: '12345',
    type: 'Speed Violation',
    speed: 95,
    limit: 60,
    amount: 10,
    location: 'Cairo-Alexandria Road',
    coordinates: { lat: 30.0444, lng: 31.2357 },
    date: 'Jan 20, 2025',
    time: '10:30 AM',
    status: 'unpaid'
  },
  {
    id: '12344',
    type: 'Speed Violation',
    speed: 85,
    limit: 60,
    amount: 10,
    location: 'Ring Road, Cairo',
    coordinates: { lat: 30.0333, lng: 31.2333 },
    date: 'Jan 19, 2025',
    time: '3:45 PM',
    status: 'unpaid'
  },
  {
    id: '12343',
    type: 'Speed Violation',
    speed: 75,
    limit: 60,
    amount: 10,
    location: 'Salah Salem St',
    coordinates: { lat: 30.0626, lng: 31.3219 },
    date: 'Jan 18, 2025',
    time: '9:15 AM',
    status: 'paid'
  }
];

export default function ViolationsListScreen({ navigateTo }: ViolationsListScreenProps) {
  const [filter, setFilter] = useState<'all' | 'unpaid' | 'paid'>('all');

  const filteredViolations = mockViolations.filter(v => {
    if (filter === 'all') return true;
    return v.status === filter;
  });

  const unpaidViolations = mockViolations.filter(v => v.status === 'unpaid');
  const totalAmount = unpaidViolations.reduce((sum, v) => sum + v.amount, 0);

  const getStatusBadge = (status: Violation['status']) => {
    const styles = {
      unpaid: { bg: '#fef3c7', text: '#f59e0b' },
      paid: { bg: '#d1fae5', text: '#22c55e' },
      disputed: { bg: '#dbeafe', text: '#3b82f6' }
    };
    const style = styles[status];
    
    return (
      <span
        className="text-xs px-2 py-1 rounded"
        style={{ backgroundColor: style.bg, color: style.text }}
      >
        {status.toUpperCase()}
      </span>
    );
  };

  return (
    <div className="min-h-screen bg-white pb-20">
      {/* Header */}
      <div className="px-4 pt-6 pb-4 border-b border-[#e5e7eb]">
        <h1 className="text-2xl text-[#1f2937] mb-1">Violations</h1>
      </div>

      {/* Summary Card */}
      <div className="px-4 py-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="rounded-xl p-4 text-white"
          style={{
            background: 'linear-gradient(135deg, #992a17 0%, #eb4425 100%)',
            boxShadow: '0px 10px 15px rgba(153, 42, 23, 0.3)'
          }}
        >
          <div className="text-sm opacity-90 mb-1">Total Unpaid</div>
          <div className="text-3xl mb-3">${totalAmount.toFixed(2)}</div>
          <div className="text-sm opacity-90 mb-3">
            {unpaidViolations.length} violation{unpaidViolations.length !== 1 ? 's' : ''}
          </div>
          <button
            onClick={() => navigateTo('payment-method', { amount: totalAmount })}
            className="w-full bg-white text-[#eb4425] py-2.5 rounded-lg hover:bg-opacity-90 transition-colors"
          >
            Pay All
          </button>
        </motion.div>
      </div>

      {/* Filter Chips */}
      <div className="px-4 pb-4 flex gap-2">
        {(['all', 'unpaid', 'paid'] as const).map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className="px-4 py-2 rounded-full text-sm transition-all"
            style={{
              backgroundColor: filter === f ? '#eb4425' : 'transparent',
              color: filter === f ? '#ffffff' : '#6b7280',
              border: filter === f ? 'none' : '1px solid #e5e7eb'
            }}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        ))}
      </div>

      {/* Violations List */}
      <div className="px-4 space-y-3">
        {filteredViolations.map((violation, index) => (
          <motion.div
            key={violation.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.05 }}
            onClick={() => navigateTo('violation-detail', violation)}
            className="bg-white border border-[#e5e7eb] rounded-xl p-4 cursor-pointer hover:shadow-md transition-shadow"
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-full bg-[#fee2e2] flex items-center justify-center flex-shrink-0">
                  <AlertTriangle className="w-5 h-5 text-[#ef4444]" />
                </div>
                <div>
                  <div className="text-base text-[#1f2937] mb-1">{violation.type}</div>
                  <div className="text-sm text-[#6b7280]">
                    {violation.speed} km/h in {violation.limit} km/h zone
                  </div>
                </div>
              </div>
              <div className="text-lg text-[#1f2937]">${violation.amount.toFixed(2)}</div>
            </div>

            <div className="flex items-center gap-4 text-xs text-[#9ca3af] mb-3">
              <div className="flex items-center gap-1">
                <MapPin className="w-3 h-3" />
                <span>{violation.location}</span>
              </div>
              <div className="flex items-center gap-1">
                <Clock className="w-3 h-3" />
                <span>{violation.date} • {violation.time}</span>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <div>{getStatusBadge(violation.status)}</div>
              {violation.status === 'unpaid' && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    navigateTo('payment-method', { amount: violation.amount });
                  }}
                  className="text-sm text-[#eb4425] hover:underline"
                >
                  Pay Now
                </button>
              )}
            </div>
          </motion.div>
        ))}
      </div>

      {filteredViolations.length === 0 && (
        <div className="px-4 py-12 text-center">
          <div className="text-6xl mb-4">🎉</div>
          <div className="text-xl text-[#1f2937] mb-2">No {filter !== 'all' ? filter : ''} violations</div>
          <div className="text-sm text-[#6b7280]">
            {filter === 'unpaid' ? 'All fines are paid!' : 'Keep up the safe driving!'}
          </div>
        </div>
      )}
    </div>
  );
}
