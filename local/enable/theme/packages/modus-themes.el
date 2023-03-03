;;; modus-themes.el -*- lexical-binding: t; -*-

(@setup (:elpaca modus-themes)
  (:option modus-themes-mixed-fonts t
	   modus-themes-prompts '(bold)
	   modus-themes-completions '((matches . (extrabold underline))
				      (selection . (semibold italic)))
	   modus-themes-org-blocks 'tinted-background
	   modus-themes-common-palette-overrides '((bg-mode-line-active bg-blue-intense)
						   (fg-mode-line-active fg-main)
						   (border-mode-line-active unspecified)
						   (border-mode-line-inactive unspecified)
						   
						   (bg-tab-bar bg-cyan-nuanced)
						   (bg-tab-current bg-cyan-intense)
						   (bg-tab-other bg-cyan-subtle)
						   
						   (fringe unspecified)

						   (underline-link border)
						   (underline-link-visited border)
						   (underline-link-symbolic border)

						   (fg-prompt cyan)
						   (bg-prompt bg-cyan-nuanced)
						   
						   (fg-completion-match-0 fg-main)
						   (fg-completion-match-1 fg-main)
						   (fg-completion-match-2 fg-main)
						   (fg-completion-match-3 fg-main)
						   (bg-completion-match-0 bg-blue-intense)
						   (bg-completion-match-1 bg-yellow-intense)
						   (bg-completion-match-2 bg-cyan-intense)
						   (bg-completion-match-3 bg-red-intense)
						   
						   (comment yellow-cooler)
						   (string green-cooler)

						   (bg-paren-match bg-magenta-intense)
						   
						   (prose-done green-intense)
						   (prose-todo red-intense)

						   (fg-heading-1 blue-warmer)
						   (fg-heading-2 yellow-cooler)
						   (fg-heading-3 cyan-cooler)
						   
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

						   (bg-region bg-ochre) ; try to replace `bg-ochre' with `bg-lavender', `bg-sage'
						   (fg-region unspecified)))

  (@theme-load-if-preferred 'modus-themes 'modus-operandi 'modus-vivendi)
  
  (custom-set-faces '(region ((t :extend nil))))

  (modus-themes-with-colors
    (custom-set-faces
     ;; Add "padding" to the mode lines
     `(mode-line ((,c :box (:line-width 10 :color ,bg-mode-line-active))))
     `(mode-line-inactive ((,c :box (:line-width 10 :color ,bg-mode-line-inactive)))))))

