<template lang='pug'>
  .b-collection_item
    .delete(
      @click="remove(link)"
    )
    .drag-handle
    input(
      type='hidden'
      v-model='link.entry_id'
      :name="fieldName('entry_id')"
    )
    input(
      type='hidden'
      v-model='link.entry_type'
      :name="fieldName('entry_type')"
    )
    input(
      type='hidden'
      v-model='link.created_at'
      :name="fieldName('created_at')"
    )
    input(
      type='hidden'
      v-model='link.updated_at'
      :name="fieldName('updated_at')"
    )
    input(
      type='hidden'
      v-model='link.imported_at'
      :name="fieldName('imported_at')"
    )
    input(
      type='hidden'
      v-model='link.source'
      :name="fieldName('source')"
    )
    .b-input.select
      select(
        v-model='link.kind'
        :name="fieldName('kind')"
      )
        optgroup(
          :label='I18n.t("frontend.external_links.groups.links")'
        )
          option(
            v-for='kindOption in kindOptionsLinks'
            :value='kindOption.last()'
          ) {{ kindOption.first() }}
        optgroup(
          :label='I18n.t("frontend.external_links.groups.watch_online")'
        )
          option(
            v-for='kindOption in kindOptionsWatchOnline'
            :value='kindOption.last()'
          ) {{ kindOption.first() }}
    .b-input
      input(
        type='text'
        v-model='link.url'
        :name="fieldName('url')"
        :placeholder="I18n.t('activerecord.attributes.external_link.url')"
        @keydown.enter='submit'
        @keydown.8='removeEmpty(link)'
        @keydown.esc='removeEmpty(link)'
      )
      span.hint.warn(
        v-if='isYoutubeKind'
      )
        | {{ I18n.t('frontend.external_links.warn.youtube') }}
      span.hint.warn(
        v-else-if='isYoutubeChannelKind'
      )
        | {{ I18n.t('frontend.external_links.warn.youtube_channel') }}
      span.hint.warn(
        v-else-if='isWatchOnlineKind'
      )
        | {{ I18n.t('frontend.external_links.warn.watch_online') }}
</template>

<script>
import { mapActions } from 'vuex';

export default {
  name: 'ExternalLink',
  props: {
    link: { type: Object, required: true },
    kindOptions: { type: Array, required: true },
    resourceType: { type: String, required: true },
    entryType: { type: String, required: true },
    entryId: { type: Number, required: true },
    watchOnlineKinds: { type: Array, required: true }
  },
  computed: {
    isYoutubeKind() {
      return this.link.kind === 'youtube';
    },
    isYoutubeChannelKind() {
      return this.link.kind === 'youtube_channel';
    },
    isWatchOnlineKind() {
      return this.watchOnlineKinds.includes(this.link.kind);
    },
    kindOptionsLinks() {
      return this.kindOptions.filter(v => !this.watchOnlineKinds.includes(v[1]));
    },
    kindOptionsWatchOnline() {
      return this.kindOptions.filter(v => this.watchOnlineKinds.includes(v[1]));
    }
  },
  mounted() {
    this.$nextTick(() => {
      $('input', this.$el).focus();
    });
  },
  methods: {
    ...mapActions([
      'remove'
    ]),
    fieldName(name) {
      if (!Object.isEmpty(this.link.url)) {
        return `${this.resourceType.toLowerCase()}[external_links][][${name}]`;
      }
      return '';
    },
    submit(e) {
      if (!e.metaKey && !e.ctrlKey) {
        e.preventDefault();
        this.$emit('add_next');
      }
    },
    removeEmpty(link) {
      if (Object.isEmpty(link.url) && this.$store.state.collection.length > 1) {
        this.remove(link);
        this.$emit('focusLast');
      }
    }
  }
};
</script>

<style scoped lang='sass'>
.b-collection_item
  &:first-child:last-child
    .drag-handle
      display: none

  .b-input
    margin-bottom: 2px

    &.select
      margin-bottom: 5px

    .hint.warn
      margin-top: 3px
      color: #fc575e

  .drag-handle
    margin-top: 3px

</style>
