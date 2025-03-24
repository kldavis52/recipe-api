FROM python:3.10.16-slim AS base
LABEL maintainer="Kyle"

ENV PYTHONUNBUFFERED=1

FROM base AS python-deps
RUN pip install pipenv
RUN apt-get update && apt-get install -y --no-install-recommends build-essential gcc

COPY Pipfile Pipfile.lock ./
COPY ./api /api
ARG DEV=false
RUN if [ $DEV = "true" ]; then PIPENV_VENV_IN_PROJECT=1 pipenv install --dev --deploy ; \
    else \
        PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy; \
    fi

FROM base AS runtime

COPY --from=python-deps /.venv /.venv
WORKDIR /api
EXPOSE 8000

RUN adduser --disabled-password --no-create-home django-user

ENV PATH="/.venv/bin:$PATH"
USER django-user
