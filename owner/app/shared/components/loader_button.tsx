import * as React from "react";
import { Button } from "~/components/ui/button";
import { Loader2 } from "lucide-react";
import type { ComponentProps } from "react";

export interface LoaderButtonProps extends ComponentProps<typeof Button> {
  isLoading?: boolean;
}

export const LoaderButton = React.forwardRef<HTMLButtonElement, LoaderButtonProps>(
  ({ children, isLoading, disabled, ...props }, ref) => {
    return (
      <Button disabled={isLoading || disabled} ref={ref as any} {...props}>
        {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
        {children}
      </Button>
    );
  }
);
LoaderButton.displayName = "LoaderButton";
