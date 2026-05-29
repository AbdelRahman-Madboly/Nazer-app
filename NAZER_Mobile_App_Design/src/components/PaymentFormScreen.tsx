import { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, CreditCard, AlertCircle } from 'lucide-react';
import { Screen } from '../App';

interface PaymentFormScreenProps {
  amount: number;
  navigateTo: (screen: Screen, data?: any) => void;
}

export default function PaymentFormScreen({ amount, navigateTo }: PaymentFormScreenProps) {
  const [cardNumber, setCardNumber] = useState('');
  const [cardName, setCardName] = useState('');
  const [expiry, setExpiry] = useState('');
  const [cvv, setCvv] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);

  const formatCardNumber = (value: string) => {
    const v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    const matches = v.match(/\d{4,16}/g);
    const match = (matches && matches[0]) || '';
    const parts = [];

    for (let i = 0; i < match.length; i += 4) {
      parts.push(match.substring(i, i + 4));
    }

    if (parts.length) {
      return parts.join(' ');
    } else {
      return value;
    }
  };

  const formatExpiry = (value: string) => {
    const v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    if (v.length >= 2) {
      return v.substring(0, 2) + '/' + v.substring(2, 4);
    }
    return v;
  };

  const handlePayment = () => {
    setIsProcessing(true);
    // Simulate payment processing
    setTimeout(() => {
      setIsProcessing(false);
      navigateTo('payment-success', { amount });
    }, 2000);
  };

  const isValid = cardNumber.replace(/\s/g, '').length === 16 &&
                  cardName.length > 0 &&
                  expiry.length === 5 &&
                  cvv.length === 3;

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="px-4 pt-6 pb-4 border-b border-[#e5e7eb] flex items-center gap-3">
        <button
          onClick={() => navigateTo('payment-method', { amount })}
          className="p-2 -ml-2 hover:bg-[#f8f9fa] rounded-lg transition-colors"
        >
          <ArrowLeft className="w-6 h-6 text-[#1f2937]" />
        </button>
        <h1 className="text-xl text-[#1f2937]">Credit Card Payment</h1>
      </div>

      {/* Amount */}
      <div className="px-4 py-6 text-center">
        <div className="text-sm text-[#6b7280] mb-2">Amount</div>
        <div className="text-4xl text-[#1f2937]">${amount.toFixed(2)}</div>
      </div>

      {/* Card Preview */}
      <div className="px-4 mb-6">
        <motion.div
          initial={{ rotateY: 0 }}
          animate={{ rotateY: 0 }}
          className="rounded-2xl p-6 h-52 relative overflow-hidden"
          style={{
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            boxShadow: '0px 10px 30px rgba(102, 126, 234, 0.4)'
          }}
        >
          <div className="flex justify-between items-start mb-8">
            <div className="text-white text-sm opacity-80">Credit Card</div>
            <CreditCard className="w-10 h-10 text-white opacity-60" />
          </div>

          <div className="text-white text-xl mb-6 tracking-wider font-mono">
            {cardNumber || '•••• •••• •••• ••••'}
          </div>

          <div className="flex justify-between items-end">
            <div>
              <div className="text-white text-xs opacity-70 mb-1">Cardholder</div>
              <div className="text-white text-sm">
                {cardName || 'FULL NAME'}
              </div>
            </div>
            <div>
              <div className="text-white text-xs opacity-70 mb-1">Expires</div>
              <div className="text-white text-sm">
                {expiry || 'MM/YY'}
              </div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Form */}
      <div className="px-4 space-y-4 mb-6">
        <div>
          <label className="block text-sm text-[#6b7280] mb-2">Card Number</label>
          <input
            type="text"
            maxLength={19}
            value={cardNumber}
            onChange={(e) => setCardNumber(formatCardNumber(e.target.value))}
            placeholder="1234 5678 9012 3456"
            className="w-full bg-[#f8f9fa] border border-[#e5e7eb] rounded-lg px-4 py-3 text-base text-[#1f2937] focus:outline-none focus:border-[#eb4425] focus:bg-white transition-colors"
          />
        </div>

        <div>
          <label className="block text-sm text-[#6b7280] mb-2">Cardholder Name</label>
          <input
            type="text"
            value={cardName}
            onChange={(e) => setCardName(e.target.value.toUpperCase())}
            placeholder="JOHN DOE"
            className="w-full bg-[#f8f9fa] border border-[#e5e7eb] rounded-lg px-4 py-3 text-base text-[#1f2937] focus:outline-none focus:border-[#eb4425] focus:bg-white transition-colors"
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm text-[#6b7280] mb-2">Expiry Date</label>
            <input
              type="text"
              maxLength={5}
              value={expiry}
              onChange={(e) => setExpiry(formatExpiry(e.target.value))}
              placeholder="MM/YY"
              className="w-full bg-[#f8f9fa] border border-[#e5e7eb] rounded-lg px-4 py-3 text-base text-[#1f2937] focus:outline-none focus:border-[#eb4425] focus:bg-white transition-colors"
            />
          </div>
          <div>
            <label className="block text-sm text-[#6b7280] mb-2">CVV</label>
            <input
              type="text"
              maxLength={3}
              value={cvv}
              onChange={(e) => setCvv(e.target.value.replace(/[^0-9]/g, ''))}
              placeholder="123"
              className="w-full bg-[#f8f9fa] border border-[#e5e7eb] rounded-lg px-4 py-3 text-base text-[#1f2937] focus:outline-none focus:border-[#eb4425] focus:bg-white transition-colors"
            />
          </div>
        </div>
      </div>

      {/* Demo Notice */}
      <div className="px-4 mb-6">
        <div className="bg-[#fef3c7] border border-[#f59e0b] rounded-lg p-4 flex items-start gap-3">
          <AlertCircle className="w-5 h-5 text-[#f59e0b] flex-shrink-0 mt-0.5" />
          <div className="flex-1 text-sm text-[#92400e]">
            <div className="mb-1">This is a demonstration</div>
            <div className="text-xs">No real payment will be made. This is for UI/UX demonstration only.</div>
          </div>
        </div>
      </div>

      {/* Pay Button */}
      <div className="px-4 pb-6">
        <motion.button
          whileTap={{ scale: 0.98 }}
          onClick={handlePayment}
          disabled={!isValid || isProcessing}
          className="w-full py-4 rounded-xl text-white transition-all flex items-center justify-center gap-2"
          style={{
            background: isValid && !isProcessing
              ? 'linear-gradient(135deg, #992a17 0%, #eb4425 100%)'
              : '#e5e7eb',
            opacity: isValid && !isProcessing ? 1 : 0.5,
            boxShadow: isValid && !isProcessing ? '0px 4px 12px rgba(235, 68, 37, 0.3)' : 'none'
          }}
        >
          {isProcessing ? (
            <>
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                className="w-5 h-5 border-2 border-white border-t-transparent rounded-full"
              />
              Processing...
            </>
          ) : (
            `Pay $${amount.toFixed(2)}`
          )}
        </motion.button>
      </div>
    </div>
  );
}
