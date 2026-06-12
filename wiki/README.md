# Wiki Source Pages

These Markdown files are written so they can either stay in the repo or be copied into the Gitea wiki repository.

Typical Gitea wiki workflow:

```bash
git clone https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles.wiki.git DotFiles.wiki
rsync -a wiki/ DotFiles.wiki/
cd DotFiles.wiki
git add -A
git commit -m "Update DotFiles wiki pages"
git push
```

If the wiki clone URL is different on your Gitea instance, open the repo wiki page and copy the clone URL shown by Gitea.
