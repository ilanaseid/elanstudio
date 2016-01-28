DB_DIR="tmp/mongolab_dump_`date +%Y%m%d-%H%M`" 
mongodump -h rs-ds035588/ds035588-a0.mongoFUN.com:35588,ds035588-a1.mongoFUN.com:35588 -d clear_cms_production -u USER -p PASSWORD -o $DB_DIR
mongorestore -h ds035758-a0.mongoFUN.com:35758 -u push_user -p  --db clear_cms_preview --drop $DB_DIR/clear_cms_production

