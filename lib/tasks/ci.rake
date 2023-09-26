# frozen_string_literal: true

namespace :ci do
  desc "Typechecking we run in CI"
  task type: :environment do
    # Sorbet type checking
    sh "bin/srb"

    # Verify tapioca gems up to date
    sh "bin/tapioca gems --verify"
    # Verify tapioca dsl up to date
    sh "bin/tapioca dsl --verify --environment=test"
    # Verify tapioca shims up to date
    sh "bin/tapioca check-shims"
  end

  desc "Linting we run in CI"
  task lint: :environment do
    # Rubocop
    sh "bin/rubocop --parallel"
    # Lint haml
    sh "bin/haml-lint"
    # Lint erb
    sh "bin/erblint --lint-all"
    # Security audit application code
    sh "bin/brakeman -q -w2"
  end
end
