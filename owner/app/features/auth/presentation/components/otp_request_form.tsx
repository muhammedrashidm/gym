import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Input } from "~/components/ui/input";
import { Label } from "~/components/ui/label";
import { LoaderButton } from "~/shared/components/loader_button";
import { Form, useSubmit } from "react-router";

const schema = z.object({
  phoneNumber: z
    .string()
    .min(1, "Phone number is required")
    .regex(/^\+?[1-9]\d{6,14}$/, "Invalid phone format (e.g. +1234567890)"),
});

type FormData = z.infer<typeof schema>;

export function OtpRequestForm({ isLoading, actionError }: { isLoading: boolean; actionError?: string }) {
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
    formData.append("_step", "request");
    formData.append("phoneNumber", data.phoneNumber);
    submit(formData, { method: "post" });
  };

  return (
    <div className="flex flex-col gap-12">
      <div>
        <h1 className="font-heading text-[2.5rem] leading-[1.05] tracking-[-0.02em] font-extrabold uppercase mb-4 text-primary">
          IDENTIFICATION
        </h1>
        <p className="text-muted-foreground text-base leading-relaxed">
          Enter your registered mobile credentials to proceed to the editorial dashboard.
        </p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-8">
        <div className="flex flex-col gap-3">
          <Label htmlFor="phoneNumber" className="text-[10px] font-bold tracking-[0.2em] uppercase text-muted-foreground">
            MOBILE CREDENTIAL
          </Label>
          <Input
            id="phoneNumber"
            type="tel"
            placeholder="+1 234 567 890"
            className="h-16 text-lg font-heading font-semibold rounded-none border-b-2 border-x-0 border-t-0 border-border focus-visible:ring-0 focus-visible:border-primary bg-surface-highest/30 px-4"
            {...register("phoneNumber")}
          />
          {(errors.phoneNumber || actionError) && (
            <p className="text-destructive text-sm font-semibold">
              {errors.phoneNumber?.message || actionError}
            </p>
          )}
        </div>

        <LoaderButton
          type="submit"
          isLoading={isLoading}
          className="h-16 rounded-none text-sm font-bold tracking-widest uppercase bg-primary text-primary-foreground hover:bg-primary/90 mt-4"
        >
          Proceed
        </LoaderButton>
      </form>
    </div>
  );
}
