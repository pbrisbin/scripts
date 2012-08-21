#!/usr/bin/awk -f

BEGIN {
  FS = "\t"

  # we use printf to not confuse vim itself if it sees an additional
  # mode line in the file.
  printf("# %s: %s=%s\n", "vim", "ft", "muttrc");
};
{
  if ($1 != "n/a" && $2 != "n/a") {
    orig = $2; gsub(" ", "_", $2);
    printf "alias %s %s <%s>\n", $2, orig, $1;
  };
};
