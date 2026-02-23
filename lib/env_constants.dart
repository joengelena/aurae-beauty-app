// ============================================================================
// Environment Configuration
// ============================================================================
// This file centralizes all environment-specific constants.
// Override defaults at build time using --dart-define flags:
//
// flutter build web --dart-define=API_BASE_URL=https://api.motorexnz.com/api/v1
//
// For development, uncomment the localhost URLs below.
// ============================================================================

// API Configuration
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  // defaultValue: 'http://localhost:4941/api/v1',
  defaultValue: 'https://motorix-api-production.up.railway.app/api/v1',
);

// Supabase Configuration
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://wrmlkvdddujmycsehlec.supabase.co', // Development
);

const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_GfRWXx4SXn6s6i6FUB0A0w_r7WWqSD6',
);

// App URLs - used for redirects from emails
const appBaseUrl = String.fromEnvironment(
  'APP_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

// Redirect URLs for auth flows
const emailVerificationRedirectUrl = '$appBaseUrl/#/profile/email-verification';

// Environment name for debugging
const environment = String.fromEnvironment(
  'ENVIRONMENT',
  defaultValue: 'development',
);
