import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { useActionData, useNavigation, Form, useSubmit } from "react-router";
import { Input } from "~/components/ui/input";
import { Label } from "~/components/ui/label";
import { LoaderButton } from "~/shared/components/loader_button";
import { Upload } from "lucide-react";

const schema = z.object({
  fullName: z.string().min(2, "Full name is required"),
  age: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

export function ProfileSetupPage() {
  const actionData = useActionData<{ error?: string }>();
  const navigation = useNavigation();
  const isSubmitting = navigation.state === "submitting";
  const submit = useSubmit();

  const [avatarPreview, setAvatarPreview] = useState<string | null>(null);
  const [avatarFile, setAvatarFile] = useState<File | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setAvatarFile(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setAvatarPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const onSubmit = (data: FormData) => {
    const formData = new FormData();
    formData.append("_action", "setup_profile");
    formData.append("fullName", data.fullName);
    if (data.age) formData.append("age", data.age);
    if (avatarFile) formData.append("avatar", avatarFile);

    submit(formData, { method: "post", encType: "multipart/form-data" });
  };

  return (
    <div className="font-sans text-foreground antialiased overflow-x-hidden min-h-screen bg-background selection:bg-primary selection:text-white">
      {/* Grain overlay */}
      <div className="fixed inset-0 bg-[url('https://lh3.googleusercontent.com/aida-public/AB6AXuBjDBCMz7H8l8nwMwr51sr_toAMkmyPYcFWbZV_ewQ8QSHNx613DPsZDjgx-4RrgfEyTEpJsQAobNXSl5n5SDzidRdGZUvQVvQ--kGcmzQR3F6GeUt5tpA-fQgW0RHKRRny2QtmaKJDtdpzoM528_mqeIcGfNwpw2LLmD4FWRmgDQzYiPohnyUxmGaRoQWqsZ7o2NNSr5ZlWAj_5_caj-b1k5lOm2g-JE-rAo0u0F-GzA4GzzwHjIAgaVYT2NIsGBDbKbQLveghL-uN')] opacity-[0.03] pointer-events-none z-50"></div>
      
      {/* Diagonal Accents */}
      <div className="fixed top-0 left-0 w-[60px] h-[60px] border-t border-l border-border z-40 pointer-events-none"></div>
      <div className="fixed bottom-0 right-0 w-[60px] h-[60px] border-b border-r border-border z-40 pointer-events-none"></div>

      {/* Desktop Top Navigation Bar */}
      <header className="fixed top-0 w-full z-50 bg-background/80 backdrop-blur-md border-b border-border/30 flex items-center justify-between px-6 lg:px-12 h-20">
        <div className="flex items-center gap-8">
          <button className="active:scale-95 transition-transform duration-150 text-foreground flex items-center gap-2 hover:opacity-70">
            <span className="material-symbols-outlined">arrow_back</span>
            <span className="font-sans text-[10px] font-bold uppercase tracking-[0.2em] hidden md:inline">BACK</span>
          </button>
          <h1 className="font-heading font-bold text-2xl text-foreground">Onboarding</h1>
        </div>
        <div className="text-2xl font-black text-foreground uppercase tracking-widest">MONOLITHIC</div>
        <div className="w-24 hidden md:block"></div> {/* Spacer to balance layout */}
      </header>

      <main className="min-h-screen pt-40 pb-24 px-6 lg:px-10 flex justify-center">
        <div className="w-full max-w-[800px] flex flex-col">
          {/* Hero Title Section */}
          <section className="w-full mb-16 text-center">
            <div className="inline-block border-l-4 border-primary pl-4 mb-6">
              <p className="font-sans text-[10px] font-bold tracking-[0.2em] uppercase text-muted-foreground text-left">PROFILE IDENTITY</p>
            </div>
            <h2 className="font-heading text-6xl md:text-7xl font-black text-primary uppercase italic leading-none">Establish Your<br />Sanctuary.</h2>
          </section>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-16 items-start">
            {/* Left Side: Avatar Upload */}
            <section className="flex flex-col items-center">
              <div className="relative group">
                <label htmlFor="avatar" className="w-64 h-64 rounded-full border-2 border-dashed border-border flex items-center justify-center overflow-hidden bg-surface-low transition-all duration-300 group-hover:border-primary group-hover:bg-surface-highest cursor-pointer">
                  {avatarPreview ? (
                    <img src={avatarPreview} alt="Avatar" className="w-full h-full object-cover" />
                  ) : (
                    <div className="text-center">
                      <span className="material-symbols-outlined text-5xl text-muted-foreground mb-3 group-hover:text-primary transition-colors">add</span>
                      <p className="font-sans text-[10px] font-bold tracking-[0.2em] uppercase text-muted-foreground group-hover:text-primary transition-colors">UPLOAD PHOTO</p>
                    </div>
                  )}
                </label>
                <input
                  type="file"
                  id="avatar"
                  accept="image/*"
                  className="hidden"
                  onChange={handleFileChange}
                />
                {/* Decorative Frame */}
                <div className="absolute -inset-4 border border-border/30 rounded-full -z-10 animate-pulse pointer-events-none"></div>
                <div className="absolute -inset-8 border border-border/10 rounded-full -z-20 pointer-events-none"></div>
              </div>
              <p className="mt-12 text-muted-foreground font-sans text-[10px] font-bold tracking-widest uppercase">Select a profile representation</p>
            </section>

            {/* Right Side: Form Fields */}
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-10">
              <div className="space-y-3">
                <label htmlFor="fullName" className="font-sans text-[10px] font-bold text-muted-foreground uppercase tracking-[0.15em] ml-1">Legal Full Name</label>
                <div className="relative group">
                  <input 
                    id="fullName"
                    className="w-full bg-surface-low h-20 px-8 font-heading text-xl font-bold text-primary border-b-2 border-transparent focus:border-primary focus:ring-0 placeholder:text-muted-foreground/40 transition-all uppercase tracking-tight focus:outline-none" 
                    placeholder="ALEXANDER KINETIC" 
                    type="text"
                    {...register("fullName")}
                  />
                  <span className="material-symbols-outlined absolute right-8 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary">badge</span>
                </div>
                {errors.fullName && (
                  <p className="text-destructive text-sm font-semibold">{errors.fullName.message}</p>
                )}
              </div>

              <div className="space-y-3">
                <label htmlFor="age" className="font-sans text-[10px] font-bold text-muted-foreground uppercase tracking-[0.15em] ml-1">Current Age</label>
                <div className="relative group">
                  <input 
                    id="age"
                    className="w-full bg-surface-low h-20 px-8 font-heading text-xl font-bold text-primary border-b-2 border-transparent focus:border-primary focus:ring-0 placeholder:text-muted-foreground/40 transition-all focus:outline-none" 
                    placeholder="28" 
                    type="number"
                    {...register("age")}
                  />
                  <span className="material-symbols-outlined absolute right-8 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary">calendar_today</span>
                </div>
              </div>
              
              {actionData?.error && (
                <p className="text-destructive text-sm font-semibold">
                  {actionData.error}
                </p>
              )}

              <div className="pt-8">
                <LoaderButton 
                  type="submit"
                  isLoading={isSubmitting}
                  className="w-full bg-primary text-primary-foreground h-20 flex items-center justify-center gap-4 active:scale-[0.98] transition-all hover:bg-primary/90 group rounded-none"
                >
                  <span className="font-sans text-xl tracking-[0.4em] font-black uppercase">Complete Profile</span>
                  <span className="material-symbols-outlined transition-transform group-hover:translate-x-1">arrow_forward</span>
                </LoaderButton>
              </div>

              {/* Technical Footer Decoration */}
              <div className="pt-10">
                <div className="w-full h-px bg-border/30"></div>
                <div className="flex justify-between mt-4">
                  <span className="font-sans text-[9px] font-bold uppercase text-muted-foreground">SYS_READY_V2.0_DESKTOP</span>
                  <span className="font-sans text-[9px] font-bold uppercase text-muted-foreground">DATA ENCRYPTION: ACTIVE (AES-256)</span>
                </div>
              </div>
            </form>
          </div>
        </div>
      </main>

      <footer className="fixed bottom-8 left-12 pointer-events-none">
        <div className="flex items-center gap-4 opacity-50">
          <div className="w-2 h-2 rounded-full bg-primary animate-pulse"></div>
          <span className="font-sans text-[10px] font-bold uppercase tracking-tighter text-foreground">SECURE CONNECTION ESTABLISHED</span>
        </div>
      </footer>
    </div>
  );
}
