export class InvalidOtpError extends Error {
  constructor() {
    super("Invalid or expired OTP");
  }
}

export class UnauthorizedError extends Error {
  constructor() {
    super("Unauthorized");
  }
}
