import { useState } from "react";
import { useActionData, useNavigation } from "react-router";
import { AuthLayout } from "~/shared/layouts/auth_layout";
import { OtpRequestForm } from "../components/otp_request_form";
import { OtpVerifyForm } from "../components/otp_verify_form";

export function LoginPage() {
  const actionData = useActionData<{
    success?: boolean;
    phoneNumber?: string;
    error?: string;
  }>();
  const navigation = useNavigation();
  const isSubmitting = navigation.state === "submitting";

  const [localPhone, setLocalPhone] = useState<string | null>(null);

  // If actionData returns a phoneNumber and success, we transition to OTP step
  const currentPhone = actionData?.success ? actionData.phoneNumber : localPhone;
  const isOtpStep = !!currentPhone && actionData?.success;

  const handleBack = () => {
    setLocalPhone(null);
    // Since we're backing out, we rely on the component state instead of action data
    // Usually this requires a fresh GET or just handling it purely client side
    window.location.href = "/login"; // Hard reset to clear action data
  };

  return (
    <AuthLayout>
      {!isOtpStep ? (
        <OtpRequestForm
          isLoading={isSubmitting}
          actionError={actionData?.error}
        />
      ) : (
        <OtpVerifyForm
          phoneNumber={currentPhone!}
          isLoading={isSubmitting}
          actionError={actionData?.error}
          onBack={handleBack}
        />
      )}
    </AuthLayout>
  );
}
