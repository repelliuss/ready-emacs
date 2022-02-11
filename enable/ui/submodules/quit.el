;;; quit.el -*- lexical-binding: t; -*-

(defvar doom-quit-messages
  '(;;from doom 2
    "Don't go now, there's a dimensional shambler waiting at the dos prompt!"
    "Get outta here and go back to your boring programs."
    "If I were your boss, I'd deathmatch ya in a minute!"
    "Look, bud. You leave now and you forfeit your body count!"
    "You're lucky I don't smack you for thinking about leaving."
    ;; from Doom 1
    "Please don't leave, there's more demons to toast!"
    "Let's beat it -- This is turning into a bloodbath!"
    "I wouldn't leave if I were you. DOS is much worse."
    "Don't leave yet -- There's a demon around that corner!"
    "Ya know, next time you come in here I'm gonna toast ya."
    "Go ahead and leave. See if I care."
    "Are you sure you want to quit this great editor?"
    ;; from Portal
    "Thank you for participating in this Aperture Science computer-aided enrichment activity."
    "You can't fire me, I quit!"
    "I don't know what you think you are doing, but I don't like it. I want you to stop."
    "This isn't brave. It's murder. What did I ever do to you?"
    "I'm the man who's going to burn your house down! With the lemons!"
    "Okay, look. We've both said a lot of things you're going to regret..."
    ;; Custom
    "(setq nothing t everything 'permitted)"
    "Emacs will remember that."
    "Emacs, Emacs never changes."
    "Hey! Hey, M-x listen!"
    "It's not like I'll miss you or anything, b-baka!"
    "Wake up, Mr. Stallman. Wake up and smell the ashes."
    "You are *not* prepared!"
    "Please don't go. The drones need you. They look up to you.")
  "A list of quit messages, picked randomly by `doom-quit'. Taken from
http://doom.wikia.com/wiki/Quit_messages and elsewhere.")

(defun doom-quit-p (&optional prompt)
  "Prompt the user for confirmation when killing Emacs.

Returns t if it is safe to kill this session. Does not prompt if no real buffers
are open."
  (or (yes-or-no-p (format "%s" (or prompt "Really quit Emacs?")))
      (ignore (message "Aborted"))))

(defun doom-quit-fn (&rest _)
  (doom-quit-p
   (format "%s  %s"
           (propertize (nth (random (length doom-quit-messages))
                            doom-quit-messages)
                       'face '(italic default))
           "Really quit Emacs?")))

(setq confirm-kill-emacs #'doom-quit-fn)

