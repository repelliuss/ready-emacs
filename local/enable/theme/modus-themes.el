;;; modus-themes.el -*- lexical-binding: t; -*-

(cfg-pkg modus-themes
  (:opt
   modus-themes-disable-other-themes t
   modus-themes-bold-constructs t
   modus-themes-italic-constructs t
   modus-themes-mixed-fonts t
   modus-themes-variable-pitch-ui nil ; FIX_UPSTREAM: doom-modeline can't calculate modeline width with variable-pitch fonts
   modus-themes-prompts '(ultrabold italic)
   modus-themes-completions '((matches . (extrabold))
				              (selection . (ultrabold italic)))
   modus-themes-common-palette-overrides
   '((fg-heading-0 blue-cooler)

     (border-mode-line-active fg-main)
     (border-mode-line-inactive unspecified)

     (bg-mode-line-inactive bg-cyan-subtle)
     (bg-mode-line-active bg-cyan-intense)
	 (fg-mode-line-active fg-main)

	 (bg-tab-bar bg-main)
	 (bg-tab-current bg-main)
	 (bg-tab-other bg-cyan-intense)

	 (underline-link border)
	 (underline-link-visited border)
	 (underline-link-symbolic border)

     (fg-line-number-inactive "gray50")
     (bg-line-number-inactive unspecified)
     (fg-line-number-active fg-main)
     (bg-line-number-active bg-cyan-intense)

	 (fg-prompt cyan-faint)
	 (bg-prompt unspecified)

	 (fg-completion-match-0 fg-main)
	 (fg-completion-match-1 fg-main)
	 (fg-completion-match-2 fg-main)
	 (fg-completion-match-3 fg-main)
	 (bg-completion-match-0 bg-blue-subtle)
	 (bg-completion-match-1 bg-yellow-subtle)
	 (bg-completion-match-2 bg-cyan-subtle)
	 (bg-completion-match-3 bg-red-subtle)

	 (comment yellow-cooler)
	 (string green-cooler)

	 (bg-paren-match bg-magenta-intense)

	 (bg-prose-block-contents bg-dim)
	 (bg-prose-block-delimiter bg-dim)
	 (fg-prose-block-delimiter fg-dim)

	 (bg-button-active bg-main)
	 (fg-button-active fg-main)
	 (bg-button-inactive bg-inactive)
	 (fg-button-inactive "gray50")

	 (prose-done green-intense)
	 (prose-todo red-intense)

	 (date-common cyan)   ; default value (for timestamps and more)
	 (date-deadline red-warmer)
	 (date-event magenta-warmer)
	 (date-holiday blue) ; for M-x calendar
	 (date-now yellow-warmer)
	 (date-scheduled magenta-cooler)
	 (date-weekday cyan-cooler)
	 (date-weekend blue-faint)

	 (mail-cite-0 blue)
	 (mail-cite-1 yellow)
	 (mail-cite-2 green)
	 (mail-cite-3 magenta)
	 (mail-part magenta-cooler)
	 (mail-recipient cyan)
	 (mail-subject red-warmer)
	 (mail-other cyan-cooler)

	 (bg-region bg-lavender) ; try to replace `bg-ochre' with `bg-lavender', `bg-sage'
	 (fg-region unspecified)))

  (modus-themes-select 'modus-operandi-deuteranopia))

