#!/bin/bash

COMMON_SETTINGS_JSON='{
        "symbols.hidesExplorerArrows": false,
        "workbench.iconTheme": "symbols",
        "workbench.activityBar.location": "hidden",
        "workbench.statusBar.visible": false,
        "editor.formatOnSave": true,

        "editor.fontFamily": "JetBrains Mono",
        "terminal.integrated.fontFamily": "CodeNewRoman Nerd Font Mono",
        "explorer.fileNesting.enabled": true,
        "editor.minimap.enabled": false,
        "explorer.compactFolders": false,
        "workbench.startupEditor": "none",
        "editor.renderLineHighlight": "gutter",
        "editor.fontLigatures": true,
        "workbench.colorTheme": "Min Dark"
    }'

COMMON_EXTENSIONS=(
    "eamodio.gitlens"
    "miguelsolorio.min-theme"
    "miguelsolorio.symbols"
)

create_profile() {
    PROFILE_NAME="$1"
    PROFILE_DATA_DIR="$HOME/code_profiles/$PROFILE_NAME/data"
    PROFILE_EXTENSIONS_DIR="$HOME/code_profiles/$PROFILE_NAME/exts"
    PROFILE_SETTINGS_DIR="$PROFILE_DATA_DIR/User"
    SETTINGS_JSON="$2"
    PROFILE_EXTENSIONS=("${@:3}")

    mkdir -p $PROFILE_DATA_DIR
    mkdir -p $PROFILE_EXTENSIONS_DIR

    for extension in "${PROFILE_EXTENSIONS[@]}"; do
        code --install-extension $extension --extensions-dir $PROFILE_EXTENSIONS_DIR --user-data-dir $PROFILE_DATA_DIR
    done

    echo "$SETTINGS_JSON" >> "$PROFILE_SETTINGS_DIR/settings.json"
}

create_cs_profile() {
    CS_PROFILE_NAME="cs"
    CS_SETTINGS_JSON=$(echo "$COMMON_SETTINGS_JSON" | jq '. + {
        "editor.wordWrap": "on",
        "csharpextensions.useFileScopedNamespace": true,
        "editor.smoothScrolling": true,
        "editor.defaultFormatter": "ms-dotnettools.csharp",
        "explorer.fileNesting.patterns": {
            "*.cshtml": "${capture}.cshtml.css, ${capture}.cshtml.cs",
            "*.razor": "${capture}.razor.cs",
        }
    }')
    CS_EXTENSIONS=(
        "${COMMON_EXTENSIONS[@]}"
        "ms-dotnettools.csdevkit"
        "kreativ-software.csharpextensions"
        "k--kato.docomment"
        "cweijan.vscode-database-client2"
        "patcx.vscode-nuget-gallery" 
    )

    create_profile "$CS_PROFILE_NAME" "$CS_SETTINGS_JSON" "${CS_EXTENSIONS[@]}"
}

create_node_profile() {
    NODE_PROFILE_NAME="node"
    NODE_SETTINGS_JSON=$(echo "$COMMON_SETTINGS_JSON" | jq '. + {
        "editor.wordWrap": "on",
        "editor.smoothScrolling": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "explorer.fileNesting.patterns": {
            "*.ts": "${capture}.js",
            "*.js": "${capture}.js.map, ${capture}.min.js, ${capture}.d.ts",
            "*.jsx": "${capture}.js",
            "*.tsx": "${capture}.ts",
            "tsconfig.json": "tsconfig.*.json",
            "package.json": "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb",
            "*.component.ts": "${capture}.component.html, ${capture}.component.scss, ${capture}.component.scss, ${capture}.component.ts, ${capture}.component.css, ${capture}.component.spec.ts"
        },
        "editor.tabSize": 2
    }')

    NODE_EXTENSIONS=(
        "${COMMON_EXTENSIONS[@]}"
        "FernandaKipper.reactcodesnippets"
        "Angular.ng-template"
        "dbaeumer.vscode-eslint"
        "esbenp.prettier-vscode"
    )

    create_profile "$NODE_PROFILE_NAME" "$NODE_SETTINGS_JSON" "${NODE_EXTENSIONS[@]}"
}

create_profile_command_alias() {
    CS_PROFILE_CODE_ALIAS='alias code-cs="code --extensions-dir $HOME/code_profiles/cs/exts --user-data-dir $HOME/code_profiles/cs/data"'
    NODE_PROFILE_CODE_ALIAS='alias code-node="code --extensions-dir $HOME/code_profiles/node/exts --user-data-dir $HOME/code_profiles/node/data"'

    if [[ "$SHELL" == "/usr/bin/zsh" ]]; then
        grep -Fxq "$CS_PROFILE_CODE_ALIAS" "$HOME/.zshrc" || echo "$CS_PROFILE_CODE_ALIAS" >> "$HOME/.zshrc"
        grep -Fxq "$NODE_PROFILE_CODE_ALIAS" "$HOME/.zshrc" || echo "$NODE_PROFILE_CODE_ALIAS" >> "$HOME/.zshrc"
        exec zsh
    elif [[ "$SHELL" == "/user/bin/bash" ]]; then
        grep -Fxq "$CS_PROFILE_CODE_ALIAS" "$HOME/.bashrc" || echo "$CS_PROFILE_CODE_ALIAS" >> "$HOME/.bashrc"
        grep -Fxq "$NODE_PROFILE_CODE_ALIAS" "$HOME/.bashrc" || echo "$NODE_PROFILE_CODE_ALIAS" >> "$HOME/.bashrc"
        exec bash
    else
        echo "Arquivo de perfil não encontrado, adicione as linhas a baixo manualmente"
        echo "$CS_PROFILE_CODE_ALIAS"
        echo "$NODE_PROFILE_CODE_ALIAS"
    fi
}

main() {
    # check if vscode is installed
    if ! command -v code >/dev/null 2>&1; then
        echo "Erro: instale o visual studio code. Link: https://code.visualstudio.com/download"
        exit 1
    fi

    # check if lq util is installed
    if ! command -v jq >/dev/null 2>&1; then
        echo "Erro: instale o utilitário jq em seus sistema. Para mais informações: https://www.certificacaolinux.com.br/comando-linux-jq/"
        exit 1
    fi
    
    create_cs_profile
    create_node_profile
    
    create_profile_command_alias
}

main
