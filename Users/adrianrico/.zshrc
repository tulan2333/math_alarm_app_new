// ... existing code ...
# Elimina la línea duplicada de JAVA_HOME
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"

# Para usar Java 11
alias java11='export JAVA_HOME=$(/usr/libexec/java_home -v 11) && export PATH=$JAVA_HOME/bin:$PATH'

# Para usar Java 17
alias java17='export JAVA_HOME=$(/usr/libexec/java_home -v 17) && export PATH=$JAVA_HOME/bin:$PATH'
// ... existing code ...