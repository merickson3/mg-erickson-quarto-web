library(bibtex)
library(bib2df)
library(xfun)
library(stringr)
library(dplyr)

# This flag forces to generate again the qmds
run.again <- TRUE

# Read bibtex for references
biblio <- read.bib("scratch/publications.bib")

# Converting bibtex to DF to loop into
biblio.df <- bib2df("scratch/publications.bib")
biblio.df <- biblio.df[biblio.df$CATEGORY %in% c("ARTICLE","MISC","INCOLLECTION"),]

# two backslash for escape, to replace brackets
biblio.df = biblio.df %>% 
  mutate(TITLE = str_replace_all(TITLE, "\\{|\\}", ""))#%>% 
  #mutate(AUTHOR = str_replace_all(AUTHOR, "\\{\\\\'o\\}", "ó")) 
  

# bibtex time stamp used to update files if needed
bib.mtime <- file.mtime("publications.bib")

for(i in 1:nrow(biblio.df)) {

  # using here to get absolute paths rather than relative paths because this is conflicting with in_dir later
  img_file <- file.path(("/pub_images"), paste0(biblio.df$BIBTEXKEY[i], ".png"))
  pdf_file <- file.path(("/pub_files"), paste0(biblio.df$BIBTEXKEY[i], ".pdf"))
  
  # --- Local paths (used for checking files on disk) ---
  img_file_local <- file.path("scratch/publications/pub_images", paste0(biblio.df$BIBTEXKEY[i], ".png"))
  pdf_file_local <- file.path("scratch/publications/pub_files",  paste0(biblio.df$BIBTEXKEY[i], ".pdf"))
  
  # --- Web paths (used in rendered HTML) ---
  img_file_web <- file.path("pub_images/", paste0(biblio.df$BIBTEXKEY[i], ".png"))
  pdf_file_web <- file.path("pub_files/",  paste0(biblio.df$BIBTEXKEY[i], ".pdf"))
  
  img_exists = file.exists(img_file_local)
  
  pdf_exists = file.exists(pdf_file_local)
  
  # We don't render qmd files if they are more recent than the bibtex file
  if (file_exists(paste0("scratch/publications/",biblio.df$BIBTEXKEY[i],".qmd"))) {
    if(bib.mtime < file.mtime(paste0("scratch/publications/",biblio.df$BIBTEXKEY[i],".qmd")) & !run.again) {
      next
    }
  }
  # quarto_render needs to be executed in the dir where the files are
  # that's why we use in_dir
  in_dir(
    "scratch/publications",
    quarto::quarto_render(
      input = "_pubtemplate.qmd", 
      output_file = paste0(biblio.df$BIBTEXKEY[i],".qmd"),
      output_format = "markdown", 
      metadata = list(title = biblio.df$TITLE[i]),
      execute_params = list(
        authors = paste0(unlist(biblio.df$AUTHOR[i]), collapse = "; "), 
        abstract = biblio.df$ABSTRACT[i], 
        ref = format(biblio[biblio.df$BIBTEXKEY[i]], style = "text"), 
        link = biblio.df$URL[i],
        year = biblio.df$YEAR[i],
        image = img_file_web , # 
        img_exists = img_exists,
        pdf_exists = pdf_exists,
        preprint = pdf_file_local) # then will save images and pdf using the key
        
      )
    )
  

}
# 
# biblio.df[7,]$URL
# biblio.df[8,]$URL
#biblio.df[8,]$AUTHOR

#biblio.df$TITLE

