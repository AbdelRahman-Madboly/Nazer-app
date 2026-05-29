import { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, CreditCard, Smartphone, Phone, Ticket, Check } from 'lucide-react';
import { Screen } from '../App';

interface PaymentMethodScreenProps {
  amount: number;
  navigateTo: (screen: Screen, data?: any) => void;
}

export default function PaymentMethodScreen({ amount, navigateTo }: PaymentMethodScreenProps) {
  const [selectedMethod, setSelectedMethod] = useState<string | null>(null);

  const paymentMethods = [
    {
      id: 'card',
      icon: CreditCard,
      name: 'Credit/Debit Card',
      description: 'Visa, Mastercard',
      color: '#3b82f6'
    },
    {
      id: 'instapay',
      icon: Smartphone,
      name: 'InstaPay',
      description: 'Instant bank transfer',
      color: '#22c55e'
    },
    {
      id: 'vodafone',
      icon: Phone,
      name: 'Vodafone Cash',
      description: 'Mobile wallet payment',
      color: '#ef4444'
    },
    {
      id: 'meeza',
      icon: Ticket,
      name: 'Meeza Card',
      description: 'National payment card',
      color: '#f59e0b'
    }
  ];

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="px-4 pt-6 pb-4 border-b border-[#e5e7eb] flex items-center gap-3">
        <button
          onClick={() => navigateTo('violations')}
          className="p-2 -ml-2 hover:bg-[#f8f9fa] rounded-lg transition-colors"
        >
          <ArrowLeft className="w-6 h-6 text-[#1f2937]" />
        </button>
        <h1 className="text-xl text-[#1f2937]">Select Payment Method</h1>
      </div>

      {/* Amount Header */}
      <div className="px-4 py-6 text-center border-b border-[#e5e7eb]">
        <div className="text-sm text-[#6b7280] mb-2">Amount to Pay</div>
        <div className="text-4xl text-[#1f2937]">${amount.toFixed(2)}</div>
      </div>

      {/* Payment Methods */}
      <div className="px-4 py-6 space-y-3">
        {paymentMethods.map((method, index) => {
          const Icon = method.icon;
          const isSelected = selectedMethod === method.id;

          return (
            <motion.button
              key={method.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => setSelectedMethod(method.id)}
              className="w-full bg-white border-2 rounded-xl p-4 flex items-center gap-4 transition-all"
              style={{
                borderColor: isSelected ? '#eb4425' : '#e5e7eb',
                boxShadow: isSelected ? '0px 4px 12px rgba(235, 68, 37, 0.2)' : '0px 1px 3px rgba(0, 0, 0, 0.1)'
              }}
            >
              <div
                className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0"
                style={{ backgroundColor: `${method.color}15` }}
              >
                <Icon className="w-6 h-6" style={{ color: method.color }} />
              </div>

              <div className="flex-1 text-left">
                <div className="text-base text-[#1f2937] mb-1">{method.name}</div>
                <div className="text-sm text-[#6b7280]">{method.description}</div>
              </div>

              <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all ${
                isSelected ? 'border-[#eb4425] bg-[#eb4425]' : 'border-[#e5e7eb]'
              }`}>
                {isSelected && <Check className="w-4 h-4 text-white" />}
              </div>
            </motion.button>
          );
        })}
      </div>

      {/* Continue Button */}
      <div className="px-4 pb-6">
        <motion.button
          whileTap={{ scale: 0.98 }}
          onClick={() => {
            if (selectedMethod) {
              navigateTo('payment-form', { amount });
            }
          }}
          disabled={!selectedMethod}
          className="w-full py-4 rounded-xl text-white transition-all"
          style={{
            background: selectedMethod 
              ? 'linear-gradient(135deg, #992a17 0%, #eb4425 100%)'
              : '#e5e7eb',
            opacity: selectedMethod ? 1 : 0.5,
            boxShadow: selectedMethod ? '0px 4px 12px rgba(235, 68, 37, 0.3)' : 'none'
          }}
        >
          Continue
        </motion.button>
      </div>

      {/* Security Notice */}
      <div className="px-4 pb-6">
        <div className="bg-[#f8f9fa] rounded-lg p-4 flex items-start gap-3">
          <div className="text-xl">🔒</div>
          <div className="flex-1 text-xs text-[#6b7280]">
            Your payment information is encrypted and secure. We never store your card details.
          </div>
        </div>
      </div>
    </div>
  );
}
