import { motion } from 'motion/react';

export default function SplashScreen() {
  return (
    <div className="h-screen w-full flex flex-col items-center justify-center bg-white">
      {/* Logo with gradient */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5, ease: 'easeOut' }}
        className="mb-4"
      >
        <div className="w-32 h-32 rounded-3xl flex items-center justify-center"
          style={{
            background: 'linear-gradient(135deg, #992a17 0%, #eb4425 100%)',
            boxShadow: '0px 20px 25px rgba(153, 42, 23, 0.3)'
          }}
        >
          <svg width="80" height="80" viewBox="0 0 80 80" fill="none">
            <path d="M40 10L50 30H30L40 10Z" fill="white" />
            <circle cx="40" cy="50" r="15" fill="white" />
            <rect x="35" y="60" width="10" height="10" fill="white" />
          </svg>
        </div>
      </motion.div>

      {/* App Name */}
      <motion.h1
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.3, delay: 0.3 }}
        className="text-5xl mb-2"
        style={{
          background: 'linear-gradient(135deg, #992a17 0%, #eb4425 100%)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          backgroundClip: 'text'
        }}
      >
        NAZER
      </motion.h1>

      {/* Version */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.3, delay: 0.5 }}
        className="absolute bottom-8 text-xs text-[#9ca3af]"
      >
        Version 1.0.0
      </motion.p>
    </div>
  );
}
