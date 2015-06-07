#!/bin/bash
# ACME Configuration Cleenex for 6.2+ Configurations
# 03/06/2013 lorenzo.mangani@gmail.com
#
# Example Usage:
#      ./aclean.sh warnings.txt SBC_backup.gz
#
# Script will produce 'SBC_backup_mod.gz' as output
#
# DISCLAIMER:
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# TLDR; USE AT YOUR OWN RISK!

version=1.5k

if [ -z "$1" ] &&  [ -z "$2" ]
then
        echo
        echo "ACME Config Cleenex v.$version"
        echo "USAGE: <script> <acme_warnings> <acme_configuration.gz>"
else
		echo
        echo "Processing $1...."
        awk '!x[$0]++' $1 > $1.new
        awk -F' ' 'BEGIN { rule=3; } { if ($rule != "" && match(tolower($0), "invalid") ) { print $3 }  }' $1.new | sed 's/^.\(.*\).$/\1/' | awk '{print "name=\x27"$0"\x27" }' > $1.orig
        awk -F' ' 'BEGIN { rule=3; } { if ($rule != "" && match(tolower($0), "invalid") ) { print $3 }  }' $1.new | sed 's/^.\(.*\).$/\1/' | awk '{print "name=\x27"$0"\x27" }' | tr "[:upper:]" "[:lower:]" | sed 's/-/_/g' | sed 's/+//g' | sed 's/^='\''\([0-9].*\)'\''$/='\''x\1'\''/' > $1.clean
        awk '!x[$0]++' $1 > $1.new
        awk -F' ' 'BEGIN { rule=3; } { if ($rule != "" && match(tolower($0), "invalid") ) { print $3 }  }' $1.new | sed 's/^.\(.*\).$/\1/' | awk '{print "Id=\x27"$0"\x27" }' > $1.id_orig
        awk -F' ' 'BEGIN { rule=3; } { if ($rule != "" && match(tolower($0), "invalid") ) { print $3 }  }' $1.new | sed 's/^.\(.*\).$/\1/' |  tr "[:upper:]" "[:lower:]" | awk '{print "Id=\x27"$0"\x27" }' | sed 's/-/_/g' | sed 's/+//g' | sed 's/^='\''\([0-9].*\)'\''$/='\''x\1'\''/' > $1.id_clean
	# elements and $VARS
        awk -F' ' 'BEGIN { rule=3; } { if ($rule != "" && match(tolower($0), "invalid") ) { print $3 }  }' $1.new | sed 's/^.\(.*\).$/\1/' | awk '{print "\$"$0 }' > $1.rules_orig
        awk -F' ' 'BEGIN { rule=3; } { if ($rule != "" && match(tolower($0), "invalid") ) { print $3 }  }' $1.new | sed 's/^.\(.*\).$/\1/' | awk '{print "\$"$0 }' | tr "[:upper:]" "[:lower:]" | sed 's/-/_/g' | sed 's/+//g' | sed 's/^='\''\([0-9].*\)'\''$/='\''x\1'\''/' > $1.rules_clean
	# elements and KEYS
        awk -F' ' 'BEGIN { rule=3; } { if ($rule != "" && match(tolower($0), "invalid") ) { print $3 }  }' $1.new | sed 's/^.\(.*\).$/\1/' | awk '{print "<key>"$0"</key>" }' > $1.keys_orig
        awk -F' ' 'BEGIN { rule=3; } { if ($rule != "" && match(tolower($0), "invalid") ) { print $3 }  }' $1.new | sed 's/^.\(.*\).$/\1/' | awk '{print "<key>"$0"</key>" }' | tr "[:upper:]" "[:lower:]" | sed 's/-/_/g' | sed 's/+//g' | sed 's/^<key>\([0-9].*\)<\/key>/<key>x\1<\/key>/' > $1.keys_clean
  # pair handling
        paste -d";" $1.orig $1.clean > $1.pair
        rm -rf $1.new $1.orig $1.clean
        paste -d";" $1.id_orig $1.id_clean > $1.id_pair
        rm -rf $1.id_new $1.id_orig $1.id_clean
        paste -d";" $1.rules_orig $1.rules_clean > $1.rules_pair
        rm -rf $1.rules_new $1.rules_orig $1.rules_clean
        paste -d";" $1.keys_orig $1.keys_clean > $1.keys_pair
        rm -rf $1.keys_new $1.keys_orig $1.keys_clean

		filename=$2
		ext="${filename##*.}"
		name="${filename%.*}"
		if [[ $ext = "gz" ]]; 
		then
			gunzip $filename
			cp $name $name.mod
			gzip $name
		else 
			cp $name $name.mod
		fi

        while read -r line; do
               echo "$line"
               orig=$(echo "$line"  | cut -f 1 -d ";" )
               new=$(echo "$line"   | cut -f 2 -d ";" )
               sed -i "s|$orig|$new|g" $name.mod
        done < $1.pair
        rm -rf $1.pair

        while read -r line; do
               echo "$line"
               orig=$(echo "$line"  | cut -f 1 -d ";" )
               new=$(echo "$line"   | cut -f 2 -d ";" )
               sed -i "s|$orig|$new|g" $name.mod
        done < $1.id_pair
        rm -rf $1.id_pair

        while read -r line; do
               echo "$line"
               orig=$(echo "$line"  | cut -f 1 -d ";" )
               new=$(echo "$line"   | cut -f 2 -d ";" )
               sed -i "s|$orig|$new|g" $name.mod
        done < $1.rules_pair
        rm -rf $1.rules_pair

        while read -r line; do
               echo "$line"
               orig=$(echo "$line"  | cut -f 1 -d ";" )
               new=$(echo "$line"   | cut -f 2 -d ";" )
               sed -i "s|$orig|$new|g" $name.mod
        done < $1.keys_pair
        rm -rf $1.keys_pair

	gzip $name.mod
        echo "Done! Configuration saved as: $name.mod.gz"

fi
