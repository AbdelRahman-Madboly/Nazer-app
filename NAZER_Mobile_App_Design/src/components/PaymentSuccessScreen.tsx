import { motion } from 'motion/react';
import { CheckCircle, Download } from 'lucide-react';
import { Screen } from '../App';

interface PaymentSuccessScreenProps {
  amount: number;
  navigateTo: (screen: Screen) => void;
}

export default function PaymentSuccessScreen({ amount, navigateTo }: PaymentSuccessScreenProps) {
  const receiptData = {
    fineId: '12345',
    amount: amount,
    method: 'Visa ****3456',
    date: new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
    time: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
    transactionId: 'TXN' + Math.floor(Math.random() * 100000)
  };

  return (
    <div className="min-h-screen bg-white flex flex-col">
      {/* Success Animation */}
      <div className="flex-1 flex flex-col items-center justify-center px-4 py-12">
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ 
            type: 'spring',
            stiffness: 200,
            damping: 15,
            delay: 0.1
          }}
          className="mb-6"
        >
          <div className="w-32 h-32 rounded-full bg-[#d1fae5] flex items-center justify-center relative">
            <CheckCircle className="w-20 h-20 text-[#22c55e]" strokeWidth={2} />
            
            {/* Confetti particles */}
            {[...Array(8)].map((_, i) => (
              <motion.div
                key={i}
                initial={{ scale: 0, x: 0, y: 0 }}
                animate={{ 
                  scale: [0, 1, 0],
                  x: Math.cos(i * 45 * Math.PI / 180) * 80,
                  y: Math.sin(i * 45 * Math.PI / 180) * 80,
                }}
                transition={{ 
                  duration: 0.8,
                  delay: 0.3,
                  ease: 'easeOut'
                }}
                className="absolute w-2 h-2 rounded-full"
                style={{ 
                  backgroundColor: ['#22c55e', '#3b82f6', '#f59e0b', '#ef4444'][i % 4]
                }}
              />
            ))}
          </div>
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="text-3xl text-[#1f2937] mb-2 text-center"
        >
          Payment Successful!
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="text-base text-[#6b7280] text-center mb-8"
        >
          Your fine has been paid successfully
        </motion.p>

        {/* Receipt */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="w-full max-w-sm bg-white border border-[#e5e7eb] rounded-xl p-6 mb-6"
          style={{ boxShadow: '0px 4px 12px rgba(0, 0, 0, 0.08)' }}
        >
          <h2 className="text-lg text-[#1f2937] mb-4 pb-3 border-b border-[#e5e7eb]">
            Receipt
          </h2>

          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-sm text-[#6b7280]">Fine #</span>
              <span className="text-sm text-[#1f2937]">{receiptData.fineId}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-[#6b7280]">Amount</span>
              <span className="text-lg text-[#1f2937]">${receiptData.amount.toFixed(2)}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-[#6b7280]">Method</span>
              <span className="text-sm text-[#1f2937]">{receiptData.method}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-[#6b7280]">Date</span>
              <span className="text-sm text-[#1f2937]">{receiptData.date}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm text-[#6b7280]">Time</span>
              <span className="text-sm text-[#1f2937]">{receiptData.time}</span>
            </div>
            <div className="flex justify-between items-center pt-3 border-t border-[#e5e7eb]">
              <span className="text-sm text-[#6b7280]">Transaction ID</span>
              <span className="text-sm text-[#1f2937] font-mono">{receiptData.transactionId}</span>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Action Buttons */}
      <div className="px-4 pb-8 space-y-3">
        <motion.button
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7 }}
          whileTap={{ scale: 0.98 }}
          className="w-full py-3.5 rounded-lg border border-[#e5e7eb] text-[#1f2937] bg-white hover:bg-[#f8f9fa] transition-colors flex items-center justify-center gap-2"
        >
          <Download className="w-5 h-5" />
          Download Receipt
        </motion.button>

        <motion.button
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          whileTap={{ scale: 0.98 }}
          onClick={() => navigateTo('home')}
          className="w-full py-3.5 rounded-lg text-white"
          style={{
            background: 'linear-gradient(135deg, #992a17 0%, #eb4425 100%)',
            boxShadow: '0px 4px 12px rgba(235, 68, 37, 0.3)'
          }}
        >
          Back to Home
        </motion.button>
      </div>
    </div>
  );
}
