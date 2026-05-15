import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Input } from "~/components/ui/input";
import { LoaderButton } from "~/shared/components/loader_button";
import { Form, useSubmit } from "react-router";

const schema = z.object({
  code: z.string().min(4, "Code must be at least 4 digits"),
});

type FormData = z.infer<typeof schema>;

export function OtpVerifyForm({
  phoneNumber,
  isLoading,
  actionError,
  onBack,
}: {
  phoneNumber: string;
  isLoading: boolean;
  actionError?: string;
  onBack: () => void;
}) {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const submit = useSubmit();

  const onSubmit = (data: FormData) => {
    const formData = new FormData();
    formData.append("_step", "verify");
    formData.append("phoneNumber", phoneNumber);
    formData.append("code", data.code);
    submit(formData, { method: "post" });
  };

  return (
    <div className="flex flex-col gap-12">
      <div>
        <h1 className="font-heading text-[2.5rem] leading-[1.05] tracking-[-0.02em] font-extrabold uppercase mb-4 text-primary">
          VERIFICATION
        </h1>
        <p className="text-muted-foreground text-base leading-relaxed">
          We've sent an access code to your device (<strong>{phoneNumber}</strong>). Please enter it below.
        </p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-8">
        <div className="flex flex-col gap-3">
          <Input
            id="code"
            type="text"
            inputMode="numeric"
            placeholder="••••••"
            maxLength={6}
            className="h-20 text-center text-3xl tracking-[0.8em] font-heading font-extrabold rounded-none border-b-2 border-x-0 border-t-0 border-border focus-visible:ring-0 focus-visible:border-primary bg-surface-highest/30"
            {...register("code")}
          />
          {(errors.code || actionError) && (
            <p className="text-destructive text-sm font-semibold text-center mt-2">
              {errors.code?.message || actionError}
            </p>
          )}
        </div>

        <div className="flex flex-col gap-4 mt-4">
          <LoaderButton
            type="submit"
            isLoading={isLoading}
            className="h-16 rounded-none text-sm font-bold tracking-widest uppercase bg-primary text-primary-foreground hover:bg-primary/90"
          >
            Authenticate
          </LoaderButton>
          <button
            type="button"
            onClick={onBack}
            className="text-xs font-bold tracking-widest uppercase text-muted-foreground hover:text-primary transition-colors py-4"
          >
            Use a different number
          </button>
        </div>
      </form>
    </div>
  );
}
